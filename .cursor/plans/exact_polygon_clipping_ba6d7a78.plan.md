---
name: Exact Polygon Clipping
overview: Replace the mixed floating-point/O’Rourke intersection path with a fast, exact Sutherland-Hodgman implementation. The implementation will use CGAL’s lazy filtered exact-construction kernel so ordinary cases retain fast machine-arithmetic performance while every returned feasible set is mathematically correct.
todos:
  - id: checkpoint-current
    content: Commit the current source and configuration state before changing intersection behavior, excluding generated build and profiling outputs.
    status: pending
  - id: filtered-exact-kernel
    content: Move intersection geometry to CGAL’s lazy filtered exact-construction representation and remove floating-point construction/conversion from its decision path.
    status: pending
  - id: exact-clipping
    content: Replace duplicate O’Rourke and floating-point clipping implementations with exact Sutherland-Hodgman clipping.
    status: pending
  - id: lower-dimensional
    content: Preserve point and segment intersections as nonempty feasible sets where downstream feasibility requires them.
    status: pending
  - id: test-intersections
    content: Add adversarial exact-geometry tests, benchmark realistic polygon sizes, and verify simplification distance regressions.
    status: pending
  - id: checkpoint-verified
    content: Commit the tested replacement as a separate working checkpoint.
    status: pending
isProject: false
---

# Exact Convex Intersection

## Contract

The intersection routine will compute the closed set \(P \cap Q\) exactly for two closed, convex planar input sets, under the exact coordinate model used by the program. It will use CGAL's lazy filtered exact-construction kernel: fast floating-point filters handle unambiguous predicates and constructions, while certified fallback arithmetic resolves uncertain cases. It will not use tolerance thresholds, floating-point area signs, bounding-box early exits, recovery paths, or after-the-fact validity filters.

The current test in `simplify_geometry.h` that rejects non-simple/non-convex/non-contained results will be deleted. It is not a correctness proof: it only tries to detect failures after an inexact traversal has already constructed an invalid result.

## Mathematical Construction

For a counter-clockwise convex polygon \(Q\), write each edge \(q_iq_{i+1}\) as the closed left half-plane
\[
H_i = \{x : \operatorname{orient}(q_i,q_{i+1},x) \ge 0\}.
\]
Then exactly
\[
P \cap Q = (((P \cap H_0) \cap H_1) \dots \cap H_{m-1}).
\]

Each clip step processes every subject boundary edge \(ab\):

- retain `b` iff its exact orientation against the clipping line is non-negative;
- when the two endpoint classifications differ, insert the exact intersection of the two supporting lines;
- coalesce only exactly identical consecutive vertices;
- remove exactly collinear middle vertices as a canonicalization step, never based on a tolerance.

Induction over `Q`’s edges establishes that the evolving set is exactly the subject intersected with the processed half-planes. No output-wide containment or convexity checks are required, because those are consequences of the recurrence.

## Implementation And Performance

- Create a source-only checkpoint commit before editing. It will include the current tracked source/configuration modifications but exclude `build-*`, binaries, profiling traces, and other generated outputs. Create a second checkpoint commit only after the replacement builds and passes its test suite.
- Use `Epeck` for all values entering, leaving, or being reused by the recurrence. EPECK is a lazy filtered kernel: common predicates use hardware arithmetic first and escalate only when their sign cannot be certified. Store line intersections as exact coordinates and never convert through `double` before a later predicate.
- Replace all duplicate paths (`convex_intersect_fast`, stack-based `convex_intersect`, and O'Rourke traversal) with a single exact Sutherland-Hodgman implementation. It has \(O(nm)\) time, predictable linear storage, and substantially less degeneracy-specific state than a linear edge-walk.
- Canonicalize each exact clip result in-place: collapse exactly equal adjacent vertices and exactly collinear middle vertices. This bounds intermediate vertex counts and keeps small-polygon clipping fast without a validation pass.
- Retain an `Intersection` value type with `Empty`, `Point`, `Segment`, and `Polygon`. The algorithm preserves a nonempty zero- or one-dimensional result; the stream-state adapter may then intentionally decide whether its invariant requires positive area.
- Update `intersect(...)`, `find_F`, and `get_longest_stab` in [simplify.cpp](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/simplify.cpp) to use the dimension-aware feasible-set state. In particular, a tangential feasible endpoint remains eligible for the next stream vertex and buffer selection.
- Apply the same geometry path in [simplify_with_gui.cpp](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/simplify_with_gui.cpp), rather than maintaining a divergent copy.
- Keep `CGAL::to_double` exclusively in rendering, logging, and serializing explicitly documented approximations; it will not influence the recurrence.

## Coordinate Model

Exact constructions are exact only relative to the values represented in the kernel. To remove floating-point ambiguity at the boundary, input coordinates and simplification parameters must be parsed and retained as exact values, rather than first parsing them as `double`. If the existing grid formula retains `sqrt(2)`, the implementation must use an exact algebraic-number-capable kernel or use a rational grid spacing no larger than the theoretical spacing. The latter preserves the paper’s error guarantee while increasing grid resolution by only a constant factor.

## Verification

- Add direct unit tests for disjoint, containment, overlapping-area, shared-edge, shared-vertex, parallel, collinear, nearly coincident, and repeated-clip cases. Compare exact result dimension and exact vertices against expected rational coordinates.
- Add property tests where every exact result vertex satisfies every exact half-plane of both inputs, and validate commutativity \(P \cap Q = Q \cap P\) as sets.
- Benchmark the exact clipper against representative stream-state polygon sizes, with a separate near-degenerate workload that forces filtered-kernel fallback. Optimize only canonicalization/allocation mechanics that leave the mathematical recurrence unchanged.
- Build both CLI and GUI targets, then rerun data set `10` and the prior regression input with the continuous Fréchet validator. The regression requirement remains distance no greater than the promised bound, while the exact intersection tests establish the geometric invariant independently of the numerical validator.