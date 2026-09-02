---
name: Diagnose Fréchet increase from prior Fix B
overview: Explain that the previously observed Fréchet of 742.40 came from Fix B (now reverted in the file), which used raw input points as segment endpoints. The current code uses grid anchor + intersection vertex and produces Fréchet 424.27, within the paper's bound (1+ε)·δ = 450.
todos:
  - id: verify_current_state
    content: Re-run `./release/simplify 1 -d 300 -e 0.5 --dist` and confirm the Fréchet is 424.27 (within the bound) and the output is 84 points.
    status: completed
  - id: optional_third_point
    content: If the user wants a stream-aligned output in the future, plan the additional `stream[cur-1]` emission as a third point per segment (keeping `buffer[1]` for the Fréchet-bound chord).
    status: pending
isProject: false
---

# Why the Fréchet distance increased (then went back to normal)

## TL;DR

The Fréchet of **742.40** that you saw earlier came from **Fix B**, which the previous chat applied and then was **reverted** in the working tree. The file currently only has **Fix A** applied (drop the duplicated closing vertex from the O'Rourke intersection polygon in [`intersect`](simplify.cpp)). With Fix B reverted, the output is 84 points and the Fréchet is **424.27** — within the paper's bound `(1+ε)·δ = 450`. So the algorithm is already in a correct state.

## Diagnosis of the 742.40 (for posterity)

Fix B changed the per-segment output in `get_longest_stab` from `(buffer[0], buffer[1])` (a grid anchor + a vertex of the intersection polygon `S_i[p]`) to `(p0, stream[cur-1])` — i.e. raw input points.

By the paper's Lemma 1 (and the proof in [Cheng–Huang–Jiang, "Simplification of Trajectory Streams"](papers/journal.pdf)), the algorithm only guarantees `d_F ≤ (1+ε)·δ` when the segment endpoints are `p` (a grid anchor) and `q` (a vertex of `S_i[p]`). Both endpoints must lie inside the free-space region so that the chord `pq` stabs every `conv(G_{v_j})` for `j = 1..a`.

With Fix B's output `(p0, stream[cur-1])`:
- `p0` is fine (it's inside `conv(G_{v_1})`).
- `stream[cur-1]` is an **input point** — it's the centre of one of the disks in the intersection, not a vertex of the intersection polygon itself. It can sit **outside** the convex polygon `S_i[p]`.
- The chord from `p0` to `stream[cur-1]` can therefore leave the convex free-space region, and intermediate input points can be far from this chord.

Empirically (on data/1 with `-d 300 -e 0.5`):

| | Old (pre-fix-A) | After Fix A only (current) | After Fix A + Fix B (the 742 case) |
|---|---|---|---|
| Output size | 1020 | **84** | 84 |
| `get_longest_stab` calls | 510 | **42** | 42 |
| Fréchet | 424.27 | **424.27** | 742.40 |
| Within paper bound `(1+ε)·δ = 450`? | yes | **yes** | **no** |

The "old" 424.27 was a coincidence — the algorithm was so broken (510 calls, each consuming ~1 input point) that the simplified polyline was effectively the input itself, so the Fréchet of "input vs input-with-duplicates" came out close to the bound.

## Current state (verified)

The current code in `simplify.cpp` has only Fix A applied. Re-running confirms:

```
$ ./release/simplify 1 -d 300 -e 0.5 --dist
The original stream of size 588 is simplified to 84 points.
  simplify.txt: 424.2694822107736
```

Both Fix A and the kept-output-as-`buffer` are present:

```940:952:simplify.cpp
    }
    simplified.emplace_back(buffer[0]);
    simplified.emplace_back(buffer[1]);
    if (viewer) {
        ...
        viewer->addSimplifiedPoint(buffer[0]);
        viewer->addSimplifiedPoint(buffer[1]);
```

`buffer[0]` = a surviving grid anchor `P[i]` (always inside `conv(G_{v_1})`).
`buffer[1]` = the first vertex of the last non-empty intersection polygon `S_i[P[i]]` (by construction inside `S_i[P[i]]`).

So the chord satisfies the paper's Lemma 1 and the Fréchet stays at 424.27 ≤ 450.

## What (if anything) to do next

If you're happy with the current 84-point output and the 424.27 Fréchet, **no changes are needed** — the working tree is already in the correct state.

If you ever want to re-introduce a "stream-aligned" output (e.g. emit `p0` and `stream[cur-1]` so the simplified polyline visibly connects to the input polyline), the right move is to add `stream[cur-1]` as a **third** simplified point per segment — not replace `buffer[1]` with it. That keeps the `buffer[1]` chord that satisfies the Fréchet bound, and adds an extra anchor at the last consumed input point. But this is an optional cosmetic change, not a correctness fix.