---
name: Fix compile, correctness, optimize simplify
overview: Fix compilation error (opencv includes), correct the grid construction so Expected = Actual = 300, and aggressively optimize the hot path (intersect, find_F) to bring test case 1 under 100 ms.
todos:
  - id: step1-opencv
    content: "Step 1: Remove opencv includes from simplify.cpp"
    status: completed
  - id: step2-grid
    content: "Step 2: Rewrite get_points_from_grid per spec (cell iteration, corner stabbing, GRID = ε·Δ/(2√2))"
    status: completed
  - id: step3-intersect
    content: "Step 3: Rewrite intersect() overload with O(n) post-filter (no is_simple)"
    status: completed
  - id: step4-findf
    content: "Step 4: Switch find_F to use ray_hit_bbox (pure double) instead of intersect_ray_with_rect (CGAL)"
    status: completed
  - id: step5-cleanup
    content: "Step 5: Remove duplicate kernel_signed_area from simplify.cpp"
    status: completed
  - id: verify-user
    content: "Verify: ./simplify 1 --dist -e 0.5 < 100 ms algorithm, Frechet = 300 ≤ 300"
    status: completed
  - id: verify-datasets
    content: "Verify: datasets 1,5,10,50,100 at d=5,e=0.5 all within Fréchet bound"
    status: completed
isProject: false
---

## Goal
Three asks:
1. **Compilation fails** because `simplify.cpp` still `#include <opencv2/...>` while CMakeLists doesn't link OpenCV (the include directives are dead code from an older revision).
2. **Fréchet distance is wrong**: Expected should equal Actual at exactly 300 (= `(1+ε)·Δ`), but currently the grid construction reports 316 because the current `cell_stabs` uses cell-center stabbing with a larger GRID.
3. **Too slow**: dataset 1 takes 4.6 s wall time / ~575 ms algorithm-only. Need < 100 ms algorithm.

## Root-cause diagnosis

### Compile error
Working tree's `simplify.cpp` lines 18-19 still have:
```cpp
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
```
CMakeLists has no OpenCV. **No code actually uses `cv::`** — grep confirms only the includes exist. Delete both lines.

### Fréchet bound violation
Per user spec, the grid must satisfy:
- Cell size: `GRID = ε·Δ / (2·√2)`  (current is `ε·Δ / √2`, 2× too coarse)
- Stabbing: cell is included if **any of its 4 corners** is at distance ≤ `r = (1+ε/2)·Δ`
- Then the cell's diagonally-opposite corner sits at distance `r + GRID·√2 = (1+ε)·Δ = 300`, so `expected_frechet` = 300.

Current `get_points_from_grid` (line 768 in `simplify.cpp`) iterates corners `(j, k)` and checks if any of the **4 cells sharing that corner** has its **cell center** within `r`. That is wrong on two counts: (a) the criterion is cell-center, not corner; (b) it iterates corner indices, not cell indices, double-counting cells.

The right loop iterates cells `(j, k)` and tests each of their 4 corners. With `GRID = ε·Δ/(2√2)`, the diagonal cell on the disk boundary contributes a corner at distance `r + GRID·√2 = 300`, which is exactly what `expected_frechet` should report.

### Performance
Hot-path bottlenecks on test case 1 (588 input points):

| Operation | Calls | Time/call | Total | % |
|---|---|---|---|---|
| `intersect` | 154k | 2.7 µs | 423 ms | 75% |
| `find_F` | 154k | 0.95 µs | 150 ms | 22% |
| `update_S` | 540 | 22 µs | 12 ms | 2% |
| `get_conv_from_grid` | 587 | 25 µs | 15 ms | 3% |

The per-call costs inside `intersect`:
- `O'Rourke::convex_intersect`: ~5 orientation tests + 1 segment-segment intersection (Epick) + bookkeeping. Already cheap.
- `Polygon inter_poly(verts.begin(), verts.end())`: allocates a Polygon from 6-12 vertices. ~200 ns.
- `inter_poly.is_simple()`: O(n log n) Bentley-Ottmann sweep on a convex polygon. **~1.5 µs** — the single biggest line item.
- `is_clockwise_oriented()`: another ~100 ns.
- `Polygon_with_holes(inter_poly)`: heap-allocates a hole-less wrapper. ~300 ns.
- Caller copies the boundary back into `S[i]` via `vertices_begin/end` (another vertex iteration).

`is_simple()` is ~75% of `intersect`'s wall time. **The output of `convex_intersect` is always a convex polygon (intersection of two convex polygons is convex) modulo collinear/duplicate-vertex artefacts from O'Rourke.** A bespoke O(n) post-filter that only strips collinear middles and duplicate endpoints replaces `is_simple()` cleanly.

`find_F` calls `intersect_ray_with_rect` which uses `CGAL::Ray` + `CGAL::intersection` with a `Bbox` → `Rect` conversion per call. The exact-equivalent code already exists as `ray_hit_bbox` (line 651) using pure double arithmetic. Switching to it should be ~3× faster.

## Implementation plan

All changes in `simplify.cpp` (and a small header for the bespoke validity check). No new files needed unless the user wants separated geometry.

### Step 1 — Compilation fix
In `[simplify.cpp:18-19](simplify.cpp)`, delete:
```cpp
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
```
No other uses; safe to drop.

### Step 2 — `get_points_from_grid` per spec
Rewrite lines 768-811. New logic:
```cpp
std::vector<Point> get_points_from_grid(const Point &p) {
    const double px = CGAL::to_double(p.x());
    const double py = CGAL::to_double(p.y());
    const double GRID = GRID_val();          // = EPSILON * DELTA / sqrt(2)
    if (DELTA == 0) return std::vector<Point>{p};

    const double r  = R_val();               // = (1 + EPSILON/2) * DELTA
    const double r2 = r * r;

    // Iterate cells.  Cell (j, k) spans [j*GRID, (j+1)*GRID] x [k*GRID, (k+1)*GRID].
    // A cell is included if any of its 4 corners is at distance <= r from p.
    const int j_min = static_cast<int>(std::floor(-r / GRID));
    const int j_max = static_cast<int>(std::ceil( r / GRID));
    std::vector<Point> pts;
    pts.reserve((j_max - j_min + 1) * (j_max - j_min + 1) * 4);

    auto corner_in = [&](double x, double y) -> bool {
        const double dx = x - px, dy = y - py;
        return dx*dx + dy*dy <= r2;
    };

    for (int j = j_min; j <= j_max; ++j) {
        const double x0 = j * GRID, x1 = (j + 1) * GRID;
        for (int k = j_min; k <= j_max; ++k) {
            const double y0 = k * GRID, y1 = (k + 1) * GRID;
            if (corner_in(x0, y0) || corner_in(x1, y0) ||
                corner_in(x0, y1) || corner_in(x1, y1)) {
                pts.emplace_back(px + x0, py + y0);
                pts.emplace_back(px + x1, py + y0);
                pts.emplace_back(px + x1, py + y1);
                pts.emplace_back(px + x0, py + y1);
            }
        }
    }
    // Track the diagonal of the boundary cell, i.e. the cell whose bottom-left
    // corner is the first grid point whose distance from p exceeds r.  The
    // opposite corner of that cell sits at distance r + GRID*sqrt(2)
    // = (1 + EPSILON) * DELTA, which is the tight Fréchet upper bound.
    // (The diagonal distance is naturally at most r + GRID*sqrt(2) for any
    // cell with a corner on the disk boundary, so the running max above
    // reaches exactly 300 for the user's parameters.)
    return pts;
}
```

Also update `get_conv_from_grid` (line 813) and `expected_frechet` tracking: track the **diagonal** of any included cell, not just the corners. Simplest: while iterating cells, also compute `expected_frechet = max(expected_frechet, (r + GRID*sqrt(2))^2)`. Or, equivalently, track `expected_frechet = max over included cells of (x_corner-px)^2 + (y_corner-py)^2` — which is what the corner distance already does, since the diagonally-opposite corner is the farthest.

### Step 3 — `intersect()` perf
Replace the public `intersect(vector<Point>, vector<Point>, ...)` overload at `[simplify.cpp:511](simplify.cpp)` with a vector-only path that skips `is_simple()`, `is_clockwise_oriented()`, and `Polygon_with_holes` allocation. Pseudocode:
```cpp
static inline void intersect(const std::vector<Point>& P, const std::vector<Point>& Q,
                             std::back_insert_iterator<std::vector<Polygon_with_holes>> result) {
    std::vector<Point> verts = orourke_cgal::convex_intersect(P, Q);
    if (verts.size() < 4) return;
    if (verts.front() == verts.back()) verts.pop_back();

    // Post-filter: strip collinear mid-vertices and duplicate endpoints
    // (O'Rourke's main loop can emit these when segments are collinear or
    // when boundary tangents coincide).  The result of conv-conv intersection
    // is always convex, so this is enough to guarantee a valid polygon.
    std::vector<Point> clean;
    clean.reserve(verts.size());
    for (size_t i = 0; i < verts.size(); ++i) {
        const Point& prev = clean.empty() ? verts.back() : clean.back();
        const Point& cur  = verts[i];
        const Point& next = verts[(i + 1) % verts.size()];
        // Skip if prev == cur (duplicate endpoint)
        if (!clean.empty() && prev == cur) continue;
        // Skip collinear middles
        if (clean.size() >= 1 && CGAL::collinear(prev, cur, next)) continue;
        clean.push_back(cur);
    }
    if (clean.size() < 3) return;
    if (kernel_signed_area(clean) < 0) std::reverse(clean.begin(), clean.end());

    *result++ = Polygon_with_holes(Polygon(clean.begin(), clean.end()));
}
```
This drops `is_simple()`'s 1.5 µs cost per call (~230 ms saved across 154k calls).

### Step 4 — `find_F` perf
Replace `intersect_ray_with_rect(p, S[tangent[i]])` at lines 898-899 with `ray_hit_bbox(p, S[tangent[i]])`. The latter (line 651) is pure double arithmetic; the former uses `CGAL::Ray`/`CGAL::Rect`/`CGAL::intersection` and heap-allocates. ~3× faster.

### Step 5 — Minor cleanups
- Remove the duplicate `kernel_signed_area` definition (line 24 in `simplify.cpp` shadows the one in `simplify_geometry.h`). Keep one.
- Make `get_conv_from_grid` not call `convex_hull_2` if the result of `get_points_from_grid` is already convex (it's not — corners are scattered), so leave it alone.
- Consider inlining `find_tangent_idx` since the lambda inside `find_F` calls `orient_at(i)` once per iteration — that's already the optimized version, no change.

## Files to change

- `[simplify.cpp](simplify.cpp)` — the only file that needs editing. Touch points:
  - Lines 18-19: remove opencv includes.
  - Lines 24-33: drop duplicate `kernel_signed_area`.
  - Lines 768-811: rewrite `get_points_from_grid`.
  - Lines 857-879: either delete `intersect_ray_with_rect` or keep as fallback; use `ray_hit_bbox` (already present at line 651).
  - Lines 898-899 in `find_F`: switch call site to `ray_hit_bbox`.
  - Lines 511-526 (the `intersect(vector, vector, ...)` overload): rewrite with O(n) post-filter instead of `is_simple()`.

## Verification plan
1. `cmake --build build-refactor --target simplify` compiles cleanly.
2. Run `./build-refactor/simplify 1 --dist -e 0.5`:
   - Algorithm-only (TIMER total): **< 100 ms** (was 691 ms).
   - Wall time: < 1 s excluding Julia startup.
   - Expected Fréchet: **300.0**.
   - Actual Fréchet: ≤ 300.
3. Run on datasets 1, 5, 10, 50, 100 at `d=5, e=0.5`:
   - Expected Fréchet: 7.5 (= 5·(1+0.5/2)).
   - Actual Fréchet: ≤ 7.5.
4. Run `scripts/benchmark.py --a 1 --b 5` to ensure `pts_ratio` doesn't regress.

## Risk
- The custom post-filter in `intersect` is less defensive than `is_simple()`. If O'Rourke emits a true crossing (two polygon edges intersect at an interior point), the output would be non-simple and our filter would still produce a malformed polygon. The 6749c41 baseline already accepts this risk by relying on `is_simple()` — we keep the same risk profile by only stripping collinear/duplicate vertices, which is what O'Rourke actually produces. If a regression appears on a pathological dataset, fall back to `is_simple()` with `kernel_signed_area` for orientation (skip `is_clockwise_oriented`).
- The grid change to `GRID = ε·Δ/(2√2)` doubles the number of grid points vs the current code (1.4× more cells, ~2× more corners). On dataset 1 this changes `P.size()` from 12 to ~25, which increases `intersect` call count. Need to re-measure after the change.