---
name: DOTS Core Benchmark
overview: Build a fair algorithm-only benchmark of `simplify` versus DOTS on IDs 1–10. DOTS threshold 1000 defines each trajectory’s Fréchet target; calibration, process startup, Qt, file I/O, and Fréchet computation are excluded from reported timings.
todos:
  - id: instrument-build
    content: Verify core-only timing markers and build `simplify` and DOTS consistently in Release mode
    status: completed
  - id: benchmark-harness
    content: Implement DOTS-threshold-1000 Fréchet calibration and repeated internal timing for IDs 1–10
    status: completed
  - id: run-verify
    content: Run the serial benchmark, validate quality matching and outputs, and summarize results
    status: completed
isProject: false
---

# DOTS Core Benchmark

## Timing Boundaries
- Keep `simplify` timing around only `simplify(stream, EPSILON, DELTA, nullptr)` in [`simplify.cpp`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/simplify.cpp); parse its `TOTAL (wall time)` value.
- Keep DOTS timing around only `DotsSimplifier::batchDotsByIndex(...)` in [`traj-compression/traj-compression/online/DOTS/DOTS_adapted.cpp`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/traj-compression/traj-compression/online/DOTS/DOTS_adapted.cpp), emitting a stable `DOTS_CORE_MS` value.
- Do not time dynamic loading, Qt application construction, argument parsing, input parsing, output writing, cleanup, or Fréchet evaluation.

## Build And Harness
- Update [`CMakeLists.txt`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/CMakeLists.txt) only as needed to build the adapted DOTS source and `simplify` consistently in Release mode.
- Refine [`scripts/compare_dots.py`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/scripts/compare_dots.py) into a reproducible IDs 1–10 harness that uses the current executable paths and robustly parses both internal timing markers.
- For every ID, run DOTS with threshold `1000`, compute its Fréchet distance, then calibrate `simplify` across the existing epsilon candidates with a target-guided delta search. Select the successful candidate with the smallest relative Fréchet mismatch; calibration runs are never included in timing statistics.

## Measurement
- Re-run the chosen DOTS and `simplify` configurations with one unreported warm-up and 20 measured repetitions per algorithm and trajectory.
- Capture internal core time only; validate every run succeeds and produces a nonempty output.
- Record median, interquartile range, retained-point count, measured Fréchet error, relative error mismatch, and the chosen `simplify` epsilon/delta in [`results/compare_dots_core.csv`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/results/compare_dots_core.csv).

## Verification And Result
- Build both targets in Release mode and run the harness serially to avoid benchmark workers competing for CPU.
- Reject or clearly flag trajectory comparisons whose closest achievable Fréchet mismatch exceeds 5%, rather than presenting them as quality-matched.
- Check edited-file diagnostics and inspect the final CSV for ten complete, finite comparisons, then summarize per-ID results and aggregate geometric-mean speed ratio without including calibration or Fréchet time.