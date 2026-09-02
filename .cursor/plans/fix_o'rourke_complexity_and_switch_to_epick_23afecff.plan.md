---
name: Fix O'Rourke complexity and switch to Epick
overview: Fix the O'Rourke algorithm's time complexity comment from O(|P|+|Q|*K) to O(|P|+|Q|), and replace Epeck usage with Epick throughout convex_intersect to avoid exact-construction overhead.
todos:
  - id: fix-complexity-comment
    content: "Fix O'Rourke complexity comment: O((|P|+|Q|)*K) → O(|P|+|Q|) in simplify.cpp lines 213-218"
    status: completed
  - id: replace-epeck-with-epick
    content: "Replace Epeck with Epick in convex_intersect: remove Pe/Qe pre-conversion, update CGAL::intersection call, remove Epeck types from if-else chain"
    status: completed
isProject: false
---

## Plan

### Change 1: Fix O'Rourke complexity comment in `simplify.cpp`

In the comment on `convex_intersect_fast` (lines 213–218), update the O'Rourke complexity claim:

- **Current:** `O((|P|+|Q|) * K)` where K is the number of crossings
- **Correct:** `O(|P| + |Q|)` — each polygon edge is examined at most twice, O(1) work per examination

This is a one-line comment fix.

---

### Change 2: Replace Epeck with Epick in `convex_intersect` (`simplify.cpp`, lines 265–398)

The `convex_intersect` function currently uses Epeck for intersection construction. Replace it entirely with Epick to avoid the per-call exact→inexact conversions.

**Specific changes:**

1. **Remove Epeck pre-conversion** (lines 293–298): Delete the `Pe`/`Qe` vectors and the conversion loop. All polygon vertices stay as `Point` (Epick).

2. **Update `CGAL::intersection` call** (lines 322–324): Change from `Epeck::Segment_2` to `Segment` (the Epick alias defined in `simplify_geometry.h`):
   ```cpp
   auto inter = CGAL::intersection(Segment(Pr[a1], Pr[a]),
                                   Segment(Qr[b1], Qr[b]));
   ```

3. **Remove Epeck types** from the `if-else` chain (lines 327–344): The current code uses `Epeck::Segment_2` and `Epeck::Point_2` to extract the intersection. Replace with the Epick `Segment` and `Point` types. The conversion back via `conv_to_inexact` is no longer needed since everything stays Epick.

4. **Clean up the `sqd` distance checks** (lines 335, 338): Keep the `1e-12` threshold — Epick's rounding is well within this tolerance.

After this change, Epeck is no longer used anywhere in `simplify.cpp`, so `conv_to_exact` and `conv_to_inexact` become unused. They can be left in `simplify_geometry.h` in case future code needs them.

---

### No changes needed elsewhere

- `simplify_geometry.h`: Keep the Epeck/Epick definitions and converters (they're still correct and may be used by other projects importing this header).
- `convex_intersect_fast`: Already uses only Epick — no changes needed.
- The `intersect` wrapper (lines 402–438) and the rest of the algorithm: Unaffected by the Epeck→Epick change in `convex_intersect`.