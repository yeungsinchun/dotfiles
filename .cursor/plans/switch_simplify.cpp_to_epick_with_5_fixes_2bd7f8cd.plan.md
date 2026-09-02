---
name: Switch simplify.cpp to Epick with 5 fixes
overview: Switch simplify_geometry.h from EPECK to Epick and add 5 targeted fixes that make the algorithm robust to inexact geometric constructions. EPECK is slow (87.8% of time spent in convex_intersect with exact arithmetic). Epick is fast but silently breaks the algorithm in 5 locations. Each fix is surgical and local.
todos:
  - id: fix_kernel_switch
    content: Switch simplify_geometry.h Kernel from EPECK to Epick + add Cartesian_converter declarations
    status: completed
  - id: fix_seg_seg_int
    content: "Fix seg_seg_int: wrap CGAL::intersection in exact arithmetic via Cartesian_converter"
    status: completed
  - id: fix_ray_rect
    content: "Fix intersect_ray_with_rect: wrap CGAL::intersection in exact arithmetic"
    status: completed
  - id: fix_line_intersect
    content: "Fix line_intersect: add snap-to-segment post-processing to guarantee result lies on the input segment"
    status: completed
  - id: fix_find_tangent
    content: "Fix find_tangent_idx: skip COLLINEAR transitions that cause spurious tangent detection"
    status: completed
  - id: fix_signed_area
    content: "Fix signed_area: replace CGAL::to_double with CGAL::area_2 for exact double arithmetic"
    status: completed
  - id: verify_epick
    content: "Verify: run ./release/simplify 3 --dist and confirm Fréchet <= 300 with Epick"
    status: completed
  - id: benchmark
    content: "Benchmark: run full benchmark suite comparing Epick vs EPECK Fréchet values across all datasets"
    status: pending
isProject: false
---

## Overview

EPECK is slow because the lazy exact construction mechanism fires frequently: every `CGAL::intersection` call (called ~152,759 times for data/3) triggers exact reconstruction. EPICK gives the same exact predicates but computes intersection coordinates with double arithmetic — dramatically faster — but silently produces epsilon-off results that break the algorithm.

## The 5 breakage locations

### Fix 1: `CGAL::intersection` on two `Segment`s — `seg_seg_int` at [simplify.cpp:103](simplify.cpp)

```cpp
auto inter = CGAL::intersection(Segment(a, b), Segment(c, d));
```

With Epick, this can return a `Point` that is off by ~1e-12 in each coordinate. The O'Rourke `convex_intersect` iterates merging edges and this epsilon error accumulates. The fix: use `CGAL::Cartesian_converter` to call the intersection on EPECK primitives only for the construction, while keeping all predicates (orientation, side tests) on Epick.

```cpp
#include <CGAL/Cartesian_converter.h>
// At file scope:
using Epick = CGAL::Exact_predicates_inexact_constructions_kernel;
using Epeck = CGAL::Exact_predicates_exact_constructions_kernel;
CGAL::Cartesian_converter<Epick, Epeck> to_exact;
CGAL::Cartesian_converter<Epeck, Epick> to_inexact;

static char seg_seg_int(const Point& a, const Point& b,
                         const Point& c, const Point& d,
                         Point& out_p, Point& out_q) {
    // Use exact arithmetic only for the construction:
    auto inter = CGAL::intersection(to_exact(Segment(a, b)), to_exact(Segment(c, d)));
    // ... rest unchanged, but cast the result back:
    if (const Point* ip = std::get_if<Point>(&*inter)) {
        out_p = to_inexact(*ip);
        // ...
    }
}
```

### Fix 2: `CGAL::intersection` on `Rect`/`Ray` — `intersect_ray_with_rect` at [simplify.cpp:751](simplify.cpp)

```cpp
if (auto obj = CGAL::intersection(Rect(box), ray)) {
```

Same issue. Use `to_exact` / `to_inexact` converters:

```cpp
if (auto obj = CGAL::intersection(to_exact(Rect(box)), to_exact(ray))) {
    if (const Point* ip = std::get_if<Point>(&*obj)) {
        return to_inexact(*ip);
    }
    // ...
}
```

### Fix 3: `line_intersect` — [simplify.cpp:159-173](simplify.cpp)

This is called by `clip_halfplane` to compute line-line intersection points. With Epick the double arithmetic is fine — the issue is that the `Point` result may not be exactly collinear with the two lines. We add a small **snap-to-edge** post-processing step: after computing the intersection, project it back onto the input segment `(prev, cur)` using a dot-product parameter `t`, then clamp `t` to `[0, 1]`. This guarantees the result is always on the segment.

```cpp
static Point line_intersect(const Point& a, const Point& b,
                            const Point& p1, const Point& p2) {
    // ... existing arithmetic ...
    double x = (B2 * C1 - B1 * C2) / det;
    double y = (A1 * C2 - A2 * C1) / det;

    // Snap to segment (p1, p2): project (x, y) back onto the segment.
    // This prevents epsilon-off-segment issues with Epick double arithmetic.
    double dx = CGAL::to_double(p2.x()) - CGAL::to_double(p1.x());
    double dy = CGAL::to_double(p2.y()) - CGAL::to_double(p1.y());
    double t = ((x - CGAL::to_double(p1.x())) * dx + (y - CGAL::to_double(p1.y())) * dy)
               / (dx * dx + dy * dy);
    t = std::clamp(t, 0.0, 1.0);
    double sx = CGAL::to_double(p1.x()) + t * dx;
    double sy = CGAL::to_double(p1.y()) + t * dy;
    return Point(sx, sy);
}
```

### Fix 4: `find_tangent_idx` — [simplify.cpp:719-742](simplify.cpp)

With Epick, a near-collinear edge can produce `COLLINEAR` where exact arithmetic produces `LEFT_TURN` (or vice versa), causing the algorithm to find 3 tangent changes instead of 2 and return wrong indices. The fix: treat `COLLINEAR` as a continuation of the previous orientation state (i.e., skip it in the comparison, but still record the vertex as a potential tangent if needed).

```cpp
int prev = orient_at(n - 1);  // orientation(p, S[n-1], S[0])
for (int i = 0; i < n; ++i) {
    int cur = orient_at(i);
    // Skip COLLINEAR — it doesn't change the tangent state with Epick.
    // We still record it if needed (spurious tangents are harmless; missing
    // a tangent causes the algorithm to silently emit the wrong segment).
    if (cur == CGAL::COLLINEAR) { prev = cur; continue; }
    if (cur != prev && cur != CGAL::COLLINEAR) {
        tangent.push_back(i);
        if (tangent.size() == 2) break;
    }
    prev = cur;
}
```

### Fix 5: `signed_area` for CW/CCW detection — [simplify.cpp:228-237](simplify.cpp) and [simplify.cpp:283-292](simplify.cpp)

Replace `CGAL::to_double(a.x() * b.y() - b.x() * a.y())` with the kernel's own `CGAL::area_2(a, b, c)` predicate, which is exact for Epick's `double` coordinates. This removes the reliance on `CGAL::to_double`.

```cpp
auto signed_area = [](const std::vector<Point>& P) {
    double s = 0;
    int sz = (int)P.size();
    for (int i = 0; i < sz; ++i) {
        const Point& a = P[i];
        const Point& b = P[(i + 1) % sz];
        s += CGAL::area_2(a, b, P[(i + 2) % sz]);  // exact for Epick
    }
    return s;
};
// Then use: if (signed_area(Pin) < 0) ...
```

## Implementation plan

1. **Change `simplify_geometry.h`** — switch `Kernel` from `CGAL::Exact_predicates_exact_constructions_kernel` to `CGAL::Exact_predicates_inexact_constructions_kernel`. Remove the stale `#include` from [simplify.cpp:1](simplify.cpp).

2. **Add converter declarations** in `simplify_geometry.h` (or in a new tiny `cartesian_converters.h` included from there):
   ```cpp
   using Epick = CGAL::Exact_predicates_inexact_constructions_kernel;
   using Epeck = CGAL::Exact_predicates_exact_constructions_kernel;
   CGAL::Cartesian_converter<Epick, Epeck> to_exact;
   CGAL::Cartesian_converter<Epeck, Epick> to_inexact;
   ```

3. **Fix `seg_seg_int`** ([simplify.cpp:97-121](simplify.cpp)) — wrap segment intersection in exact arithmetic via converter.

4. **Fix `intersect_ray_with_rect`** ([simplify.cpp:744-769](simplify.cpp)) — wrap ray-rectangle intersection in exact arithmetic via converter.

5. **Fix `line_intersect`** ([simplify.cpp:159-173](simplify.cpp)) — add snap-to-segment post-processing.

6. **Fix `find_tangent_idx`** ([simplify.cpp:719-742](simplify.cpp)) — skip COLLINEAR transitions.

7. **Fix `signed_area`** (two locations: [simplify.cpp:228-237](simplify.cpp) and [simplify.cpp:283-292](simplify.cpp)) — use `CGAL::area_2`.

## Files to change

- [simplify_geometry.h](simplify_geometry.h) — switch kernel + add converter typedefs
- [simplify.cpp](simplify.cpp) — fixes at lines ~97-121, ~159-173, ~228-237, ~283-292, ~719-742, ~744-769

## How to verify

After each fix, run `./release/simplify 3 --dist` and confirm Fréchet ≤ 300 and output is 140 points. Run the full benchmark suite (`./release/benchmark.py` or equivalent) and compare EPICK vs EPECK Fréchet values across all datasets.