---
name: Update benchmark to include simplify_SH
overview: Modify `run_benchmark.py` to include simplify_SH in the full Frechet distance comparison alongside DP, DOTS, and SQUISH.
todos:
  - id: update-script
    content: Update run_benchmark.py to add Frechet distance computation for all algorithms
    status: pending
  - id: run-benchmark
    content: Run the updated benchmark to generate all simplify_SH files and compute Frechet distances
    status: pending
isProject: false
---

## Plan: Update `run_benchmark.py` to Compare simplify_SH with All Algorithms

### Overview
Modify `run_benchmark.py` to:
1. Run simplify_SH (using release build) for each ID
2. Compute Frechet distance for ALL algorithms (DP, DOTS, SQUISH, simplify_SH) vs original
3. Write results to a single comparison CSV with columns for each algorithm's points and Frechet distance

### Changes to `run_benchmark.py`

1. **Import Frechet distance function** from the `benchmark` script:
   - Copy `_frechet_distance`, `_read_curve`, `_calc_frechet_safe_task` helpers

2. **Update `process_id()` function** to:
   - Run all 4 algorithms (DP, simplify_SH, DOTS, SQUISH) - already done
   - After running all algorithms, compute Frechet distance for each:
     - `original` vs `DP.txt` → dp_frechet
     - `original` vs `DOTS.txt` → dots_frechet
     - `original` vs `SQUISH.txt` → squish_frechet
     - `original` vs `simplify_SH.txt` → sh_frechet
   - Write one CSV row per ID with all results

3. **Output CSV columns**:
   `id, orig_points, dp_points, dp_frechet, dots_points, dots_frechet, squish_points, squish_frechet, sh_points, sh_frechet`

4. **Handle missing files**: write `-1` for missing points/frechet

5. **Keep release build path** for simplify_SH: `REPO_ROOT / "release" / "simplify_SH"`