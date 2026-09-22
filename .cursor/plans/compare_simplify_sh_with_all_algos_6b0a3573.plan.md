---
name: Compare simplify_SH with all algos
overview: Create a script that compares simplify_SH against DP, DOTS, and SQUISH using Frechet distance. This includes generating simplify_SH files for all missing IDs and computing Frechet distances to original trajectories.
todos:
  - id: create-script
    content: Create compare_sh.py script with Frechet distance comparison
    status: pending
  - id: run-comparison
    content: Run compare_sh.py to generate simplify_SH files and compute all Frechet distances
    status: pending
isProject: false
---

## Plan: Full Frechet Comparison of simplify_SH vs All Algorithms

### Overview
Create a new script `compare_sh.py` that:
1. Runs simplify_SH for all IDs (generating `data/<id>/simplify_SH.txt`)
2. Computes Frechet distance between original and each algorithm's output
3. Writes results to `sh_comparison.csv`

### Steps

1. **Create `compare_sh.py`** in repo root with:
   - Run simplify_SH (release build, timeout=120s) for each ID
   - Compute Frechet distance: original vs DP, original vs DOTS, original vs SQUISH, original vs simplify_SH
   - Output CSV with columns: `id, orig_points, dp_points, dp_frechet, dots_points, dots_frechet, squish_points, squish_frechet, sh_points, sh_frechet`

2. **Handle missing algorithm outputs**:
   - If any algorithm's file is missing, write `-1` for that row's points/frechet
   - Continue processing other algorithms

3. **Use release build** for simplify_SH (already verified working)

4. **Run the comparison** for all 999 IDs with parallel workers

### Key Files
- `simplify_SH.txt` - output from simplify_SH algorithm
- `DP.txt` - existing output from Douglas-Peucker
- `DOTS.txt` - existing output from DOTS
- `SQUISH.txt` - existing output from SQUISH
- `sh_comparison.csv` - new output CSV with all Frechet distances