---
name: Fix MC preprocess split
overview: Harden question-number detection so anchors share one vertical rail per page, tighten crops to drop headers/footers, then add a splitter that turns anchored pages into per-question PNGs under `DSE/processed/2012/`.
todos:
  - id: fix-detect
    content: "Harden detect_labels: left-strip OCR, rail x-cluster, prefer N., reject off-rail/out-of-order"
    status: completed
  - id: fix-crop-validate
    content: Tighten header/footer crop; PNG embed; tolerant rail alignment validation
    status: completed
  - id: add-split
    content: "Add split_mc.py: marker-based per-question PNG export with cross-page stitch"
    status: completed
  - id: run-2012
    content: Regenerate anchored_2012p1a.pdf and write processed/2012/q1.png..q36.png; clean _inspect
    status: completed
isProject: false
---

# Fix MC anchoring and split 2012 into PNGs

## Problem diagnosis

[`DSE/scripts/preprocess_mc.py`](DSE/scripts/preprocess_mc.py) already draws markers on a fixed `rail_x`, but detection and validation are weak:

- **OCR false/missed labels:** left-margin TSV matches any `\d{1,2}` in a wide band. Sub-points and bare digits compete with real `N.` / `*N.` labels. On 2012 page 1, current OCR often **misses `1.`** and only finds `2.`/`3.`; on 2015, sub-points like `(1)(2)(3)` sit near the same band and can steal Y positions (your q1–q3 example).
- **No rail filter:** question numbers are vertically aligned (~x 50–55), but candidates at other x are accepted.
- **Alignment validator is a no-op after JPEG:** markers are saved as JPEG, so exact RGB `(13,77,242)` rarely survives. `validate_marker_alignment` then finds zero centres and never fails.
- **Crop still keeps chrome:** fixed `--bottom` leaves footers like `2015-DSE-PHY 1A-2`; top can keep “Section A” when the first label is wrong.

## Approach

```mermaid
flowchart LR
  src[Year/MC/2012p1a.pdf] --> preprocess[preprocess_mc.py]
  preprocess --> anchored[preprocessed/anchored_2012p1a.pdf]
  anchored --> split[split_mc.py]
  split --> pngs[processed/2012/q1.png ...]
```

### 1. Fix detection in `preprocess_mc.py`

In `detect_labels` (and a small post-pass over all page candidates):

- OCR a **narrow left strip** (roughly source x 30–95) so body text/digits are less likely to match.
- Prefer tokens matching `\*?(\d{1,2})\.` over bare digits; keep confidence when available.
- **Cluster by x** on each page; take the densest/leftmost cluster as the question rail; **reject** candidates farther than ~10 pt from that rail (kills sub-point columns).
- When several hits share a number, keep the rail hit with best score (period form + confidence + topmost).
- After filling all pages: enforce **increasing question order by (page, y)**; if a number is out of order or duplicated off-rail, drop and require `--overrides` rather than silently keeping a bad Y.
- Keep existing `--overrides` / `--reference` paths.

### 2. Fix drawing, crop, and validation

- Keep a single `rail_x` for all markers on a page (already intended).
- Crop each output page to question content only:
  - `top ≈ first_label_y - pad`
  - `bottom ≈` just below last question block: either a short distance under the last label, or above detected footer text (`DSE-PHY`, page id), not a fixed 779 that keeps the footer line.
- Embed pages as **PNG** (or lossless) instead of JPEG so blue markers stay exact for QA.
- Make `validate_marker_alignment` use a **tolerant blue threshold** and require **≥1 marker and shared x within ~1 pt** (fail if empty or drifted).

### 3. Add `DSE/scripts/split_mc.py`

New script: read an anchored PDF → find blue circle markers (tolerant color) top-to-bottom per page → assign sequential question numbers → write:

`DSE/processed/{year}/q{n}.png`

Crop rules:

- Vertical: from slightly above marker *n* to slightly above marker *n+1* (or page end).
- If content exists above the first marker on a page, treat it as continuation of the previous question and **stitch** vertically (covers rare multi-page stems).
- Horizontal: drop the left anchor gutter (markers + blue labels) and use the already-cropped page width; no footer (anchored pages should already exclude it after the preprocess fix).
- Output clean question imagery only (no blue dots).

CLI shape: `python split_mc.py preprocessed/anchored_2012p1a.pdf processed/2012 --questions 36`

### 4. Run for 2012

- Re-run preprocess on [`DSE/Year/MC/2012p1a.pdf`](DSE/Year/MC/2012p1a.pdf) → [`DSE/preprocessed/anchored_2012p1a.pdf`](DSE/preprocessed/anchored_2012p1a.pdf) with `--questions 36` (and overrides only if the stricter detector still misses labels).
- Spot-check page 1 markers: same x, Y flush with `1.`/`2.`/`3.`.
- Run split → `DSE/processed/2012/q1.png` … `q36.png`.
- Delete temporary [`DSE/preprocessed/_inspect/`](DSE/preprocessed/_inspect/) used during diagnosis.

**Out of scope for this run:** regenerating every year under `Year/MC/`. Script fixes will apply generally; only 2012 PNGs are produced unless you ask to batch the rest later. A quick smoke re-anchor of 2015 page 1 can be used during implementation to confirm the q1–q3 class of bugs is gone.
