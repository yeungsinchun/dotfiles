---
name: Anchor 2012 MC
overview: Create a marked copy of the 2012 Paper 1A multiple-choice PDF, adding one blue dot immediately above and left of every question number (1–36).
todos: []
isProject: false
---

# Anchor 2012 MC Questions

## Source And Output
- Read [Year/MC/2012p1a.pdf](/Users/sinchunyeung/Documents-local/Materials/Phy/DSE/Year/MC/2012p1a.pdf) and create [preprocessed/anchored_2012p1a.pdf](/Users/sinchunyeung/Documents-local/Materials/Phy/DSE/preprocessed/anchored_2012p1a.pdf).

## Processing
- Extract word-level text geometry from every source page and identify the standalone question labels `1.` through `36.` while excluding answer options and incidental numeric text.
- Add a small opaque blue circular marker just above-left of each detected question number, preserving the original page dimensions and all source content.
- Create the `preprocessed` directory only as needed for the final output.

## Validation
- Verify exactly 36 markers were written, with one marker for each expected question number.
- Render/check the resulting pages to confirm markers are visible, do not cover question numbers, and remain attached to the intended question blocks.