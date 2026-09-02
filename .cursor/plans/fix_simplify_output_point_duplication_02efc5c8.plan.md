---
name: Fix simplify output point duplication
overview: "Fix two bugs in [simplify.cpp](simplify.cpp) that cause the simplified curve to grow larger than the input: a duplicated closing vertex in `convex_intersect`/`intersect`, and an output that emits up to 2*|P| points per segment instead of 2."
todos: []
isProject: false
---

# Fix: Simplified output is larger than the input

## Observed problem

Running `./simplify 1 -d 300 -e 0.5 --dist` on the 588-point stream reports:

```
The original stream of size 588 is simplified to 1020 points.
```

A simplified curve must be **no larger** than the input. With `-d 300 -e 0.5` the algorithm should reduce 588 points to far fewer. The timing report also shows `get_longest_stab` was called **510 times** on a 588-point stream — i.e. almost every input point triggered a new segment, which is wrong.

## Root cause — two related bugs in [simplify.cpp](simplify.cpp)

### Bug A (primary cause of `find_F` going wrong and growing): duplicated closing vertex

`orourke_cgal::convex_intersect` returns the intersection polygon with the first vertex appended at the end to "close" it:

```379:381:simplify.cpp
    // Close the polygon.
    out.push_back(p0);
    return out;
```

The caller then constructs a `CGAL::Polygon` and copies **every** vertex into `S[i]` for the next iteration:

```922:926:simplify.cpp
            S[i].clear();
            std::copy(new_S[i].begin()->outer_boundary().vertices_begin(),
                      new_S[i].begin()->outer_boundary().vertices_end(),
                      std::back_inserter(S[i]));
```

`CGAL::Polygon` does **not** require the input ring to be closed — the duplicated trailing vertex is stored as a real corner. On the **next** call to `find_F`, this extra coincident vertex is treated as a corner of the convex polygon, the tangent search in `find_tangent_idx` sees a (possibly) zero-area sign change at that vertex, and `find_F` produces a free-space polygon that is too large. The intersection `F ∩ G_i` then stays large (often equal to `F` itself), so the alive `S[i]` never shrinks and never dies. The 510 `get_longest_stab` calls are the visible symptom.

### Bug B (the 588 -> 1020 overcount): wrong output points

`get_longest_stab` writes into `buffer` inside the per-`i` loop, so each alive index `i` overwrites the **same** `buffer[0]` and `buffer[1]` with values that were never meant to be segment-level output:

```906:909:simplify.cpp
            assert(new_S[i].size() == 1);
            buffer[0] = P[i];
            buffer[1] = *new_S[i].begin()->outer_boundary().vertices_begin();
        }
```

At the end it does:

```935:936:simplify.cpp
    simplified.emplace_back(buffer[0]);
    simplified.emplace_back(buffer[1]);
```

For the very first call to `get_longest_stab`, `P` has one entry per grid cell around `p0` (typically many), and **all** of them are still alive after the first stream point. So the loop runs `|P|` times and overwrites `buffer[0]/buffer[1]` `|P|` times — but only the **last** overwrite is kept. So this bug, by itself, only ever contributes **2 points per call to `get_longest_stab`**, not `2 * |P|`.

So the dominant cause of the 1020 = ~1.7x inflation is **Bug A** (the algorithm degenerates and runs ~1 call per input point, instead of skipping many input points per call). Fixing Bug A is the main fix; Bug B then still needs the small cleanup of writing the segment endpoints (the actual `p0` and the latest `pi`) instead of stale per-`i` state.

## The fix

### Fix A — drop the duplicated closing vertex before constructing the `CGAL::Polygon`

In the free function `intersect` ([simplify.cpp:386-416](simplify.cpp)), the `orourke_cgal::convex_intersect` result is now consumed as if it were an **open** ring. Strip the trailing `p0` (which is identical to the first vertex) before building the `CGAL::Polygon`:

```406:415:simplify.cpp
    if (verts.size() < 4) return;          // <3 real vertices -> nothing to do
    if (verts.front() == verts.back())     // O'Rourke closes the ring; CGAL doesn't need it
        verts.pop_back();

    Polygon inter_poly(verts.begin(), verts.end());
    if (!inter_poly.is_simple()) return;
    if (inter_poly.is_clockwise_oriented()) inter_poly.reverse_orientation();
    *result++ = Polygon_with_holes(inter_poly);
```

`Point` from `CGAL::Exact_predicates_inexact_constructions_kernel` supports `operator==` via the kernel, so `verts.front() == verts.back()` is well-defined.

### Fix B — emit the segment endpoints, not the per-index state

Replace the per-`i` `buffer` writes in [simplify.cpp:906-909](simplify.cpp) with a single update of the **segment's** start/end, computed outside the per-`i` loop. The segment's first point is `p0` (known at line 829), and its last point is whichever `stream[cur-1]` survived the longest — or simply the input `p0` itself for a 1-point segment.

Concretely, after the per-`i` loop finishes, derive:

- `segment_start = p0` (this is the stab's anchor, always emitted as the first simplified point).
- `segment_end = stream[cur-1]` (the last input point the stab reached; this is what makes a "longest stab" actually long).

Place these assignments **after** the `dead_cnt == P.size()` early break, using `cur-1` as the last consumed index. Then in the `if (viewer) { ... }` block at line 937, add `stream[cur-1]` as a simplified point (in addition to `p0`) so the GUI reflects the same thing.

The minimal edit is to remove the `buffer[0] = P[i]; buffer[1] = *new_S[i].begin()->...;` writes inside the per-`i` loop, and add, just before the `viewer->addSimplifiedPoint(buffer[0])` call:

```cpp
    simplified.emplace_back(p0);
    if (cur > 0) simplified.emplace_back(stream[cur - 1]);
```

(plus a `viewer->addSimplifiedPoint(stream[cur - 1])` in the GUI block).

## Files to change

- [simplify.cpp](simplify.cpp):
  - `intersect` (around line 406): drop the duplicated closing vertex from `verts` before building the `Polygon`. Bump the "size < 3" guard to "< 4" accordingly.
  - `get_longest_stab` (around lines 842, 908-909, 935-936): remove the `buffer` state, and emit `p0` and `stream[cur-1]` directly into `simplified`. Update the GUI calls accordingly.

## Verification

After the fix, the same command on the same input should report something like:

```
The original stream of size 588 is simplified to < 200 points.
```

with `get_longest_stab` called far fewer than 588 times, and `--dist` should still report a Fréchet distance close to (and not exceeding) `expected_frechet` printed just above.