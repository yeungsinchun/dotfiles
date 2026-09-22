---
name: Switch O'Rourke to Epick
overview: Replace Epeck with Epick (double-precision) in orourke_cgal::convex_intersect and its closures, drop the dead --intersect help text, and verify correctness + speed on test cases 1, 3, 10.
todos:
  - id: switch-orourke-to-epick
    content: Modify orourke_cgal::convex_intersect and its closures to use Epick instead of Epeck
    status: completed
  - id: remove-help-text
    content: Remove --intersect help text from print_help
    status: completed
  - id: rebuild
    content: Rebuild the binary
    status: completed
  - id: verify-test-1
    content: Run ./simplify 1 --dist and verify Fréchet ≈ 300, ~94 points, total time ~0.1s
    status: completed
  - id: verify-test-3
    content: Run ./simplify 3 --dist and verify correct Fréchet and simplified point count
    status: in_progress
  - id: verify-test-10
    content: Run ./simplify 10 --dist and verify correct Fréchet and simplified point count
    status: in_progress
isProject: false
---

# Optimize convex intersection: Epeck → Epick

## Goal
Reduce total runtime from ~1.32 s to ~0.1 s on test case 1 by replacing the exact-construction kernel (Epeck) used in `orourke_cgal::convex_intersect` with the inexact-construction kernel (Epick). The reference O'Rourke C code is pure double-precision, so the speedup is expected. Quality guarantee (Fréchet distance ≈ 300, ≈94 simplified points) must be preserved.

## Why this is safe
- The current Epeck usage in the O'Rourke path was inherited from a previous fix targeted at `convex_intersect_fast` (Sutherland-Hodgman). O'Rourke doesn't compound rounding error across edges, so it doesn't need exact construction.
- `CGAL::orientation` (predicates) is **exact** in both Epick and Epeck — only the *construction* (intersection point coordinates) differs.
- `intersect()` at [simplify.cpp:447](simplify.cpp) only calls `orourke_cgal::convex_intersect` (confirmed: `convex_intersect_fast` is defined but never referenced).

## File changes

### 1. [simplify_geometry.h](simplify_geometry.h) — add Epick converter aliases
No structural change needed; `Epick` and `Epeck` aliases are already defined. The `conv_to_exact` / `conv_to_inexact` converters stay — they're used by `clip_halfplane` and the Epeck `point_in_convex_poly` (still called from the closure path).

### 2. [simplify.cpp](simplify.cpp) — convert O'Rourke path to Epick

**`orourke_cgal::convex_intersect` (line ~310-443):**
- Remove `std::vector<Epeck::Point_2> Pe(n), Qe(m);` and the conversion loop.
- Replace the `Epeck::Segment_2` intersection with `Epick::Segment_2`:
  - `CGAL::intersection(Epick::Segment_2(Pr[a1], Pr[a]), Epick::Segment_2(Qr[b1], Qr[b]))`
  - Drop the `conv_to_inexact(...)` calls (the result is already `Epick::Point_2`).
  - The `code == 'v'` detection can be done directly: `if (p == Qr[b1] || p == Qr[b])` since exact equality is the right test for "endpoint on the other segment" once construction is double-precision.

**`orourke_cgal::point_in_convex_poly` / `all_points_in_convex_poly` (line ~129-149):**
- These are called from `convex_intersect`'s closure path (lines 435-436). Use Epick directly:
  - `Epick::orientation(a, b, p)` instead of `Epeck::orientation(ae, be, pe)`.
  - Drop `conv_to_exact` conversions.

**Leave untouched (dead code on hot path):**
- `line_intersect` (line ~156)
- `clip_halfplane` (line ~204)
- `convex_intersect_fast` (line ~254)
- These are `static` and unused — the compiler will eliminate them. Keeping them avoids out-of-scope risk.

**`print_help` (line ~508-528):**
- Remove the line mentioning `--intersect {cgal|orourke}`. The flag was advertised but never wired into the argument parser; the active path is already O'Rourke. Per user direction, remove the flag entirely.

## Verification

Build, then run the three test cases that were specified:

```bash
cd /Users/sinchunyeung/Simplification-of-Trajectory-Streams
# (rebuild — confirm exact command in existing build script or Makefile)
./simplify 1 --dist
./simplify 3 --dist
./simplify 10 --dist
```

For each case, capture and compare:
- Timing summary: `intersect` total should drop from ~1133 ms to ~10–20 ms (target ~0.1 s overall).
- `Expected Frechet distance` line and the printed Frechet value via the Julia wrapper: must remain 300.00 (within rounding tolerance of ~1e-6) for test 1, and analogous expected values for 3 and 10.
- Simplified point count: 94 for test 1 (and corresponding counts for 3, 10).

If any test fails the Fréchet-distance check or produces a different point count, stop and investigate before proceeding (do not loosen tolerances silently).

## Out of scope
- Removing the unused `convex_intersect_fast` / `clip_halfplane` / `line_intersect` helpers.
- Converting `convex_intersect_fast` to Epick (different correctness story).
- Profiling-driven micro-optimizations beyond the kernel switch.