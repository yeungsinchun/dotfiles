---
name: Rewrite benchmark script
overview: Rewrite `run_benchmark.py` to compare simplify_SH against DP, DOTS, and SQUISH across epsilon values 0.25, 0.5, 0.75 using Frechet distance.
todos:
  - id: rewrite
    content: Rewrite run_benchmark.py with correct structure
    status: completed
  - id: verify-julia
    content: Verify Julia frechet command works
    status: completed
  - id: run
    content: Run benchmark for all IDs
    status: completed
isProject: false
---

## Plan: Rewrite `run_benchmark.py`

### Algorithm Loop Structure

For each baseline algorithm (DOTS, SQUISH, DP):

```
1. Run algo on original.txt → output algo_simplified.txt
2. Compute frechet_dist via Julia library
3. For e in {0.25, 0.5, 0.75}:
   - d = frechet_dist / (1 + e)
   - Run simplify_SH with delta=d, epsilon=e → SH_<e>.txt
   - Compute frechet_dist for SH_<e>.txt
4. Append row to compare_points.csv
```

### CSV Output (`compare_points.csv`)

Columns per baseline algorithm group (multiple rows per ID):
- `id`, `baseline_algo`, `e`, `d`
- `orig_points`, `baseline_points`, `sh_points`
- `baseline_frechet`, `sh_frechet`
- `baseline_time_s`, `sh_time_s`

### Key Implementation Details

1. **Frechet via Julia**: Use `jl -e 'using TrajecComp; frechet(...)'` or similar. Need to check Julia's frechet library path.

2. **simplify_SH path**: `REPO_ROOT / "release" / "simplify_SH"`

3. **Output files per ID**:
   - `DP.txt`, `DOTS.txt`, `SQUISH.txt` (baseline)
   - `SH_0.25.txt`, `SH_0.5.txt`, `SH_0.75.txt` (simplify_SH outputs)

4. **Parallel execution**: `--workers` flag for ThreadPoolExecutor

5. **append mode**: Create CSV if absent, append rows otherwise

6. **Error handling**: Skip failed runs, write `-1` for missing values

### Files Modified
- `run_benchmark.py` - complete rewrite
- `compare_points.csv` - created if absent