---
name: Open Source Cleanup
overview: Make the repository easier to understand and reproduce by aligning the README with the actual layout and commands, adding a clear MIT licensing setup, and providing a reliable data-download plus smoke-test workflow.
todos:
  - id: license
    content: Add MIT LICENSE and document licensing/attribution boundaries.
    status: in_progress
  - id: ignore-cleanup
    content: Harden .gitignore for builds, traces, generated data, caches, and benchmark outputs.
    status: pending
  - id: dataset-cli
    content: Make the dataset downloader installable/useful with predictable local output and validation.
    status: pending
  - id: smoke-test
    content: Add a lightweight end-to-end smoke test for data preparation and simplification.
    status: pending
  - id: readme-sync
    content: Rewrite README workflow and repository map to match actual commands and targets.
    status: pending
  - id: verify
    content: Verify configure/build, smoke test, helper error paths, and ignore behavior.
    status: pending
isProject: false
---

# Open-Source Cleanup Plan

## Findings
- The repository has a reasonable research-project core, but the public-facing structure is currently cluttered by mixed concerns: algorithm sources, vendored baselines, papers/reports, notebooks, generated results, and local build/profiling directories.
- The README is substantial but not fully current. In particular, it references `download_dataset.py` and `clean_data.sh` without their `scripts/` prefix, documents targets that are not all defined in the current top-level `CMakeLists.txt`, and describes a 102-trajectory checkout even though `data/` is ignored and no committed sample inputs are present in the current tree.
- The current dataset helper only downloads and prints the Kaggle cache location; it does not place data in a predictable project-local location or validate the expected layout for `normalize`.
- There is no explicit MIT license file, and `.gitignore` does not comprehensively cover profiling traces, generated build directories, Python caches, benchmark outputs, or generated data variants.

## Implementation
- Add an MIT `LICENSE` file with the repository copyright holder/year based on the project identity already present in the repository.
- Update `.gitignore` for reproducible open-source development: ignore CMake/build output (`build-*`, `release/`, `debug/`), profiler traces, generated trajectory files and benchmark CSVs/images, notebook checkpoints, Python caches, and local dataset cache/symlink locations while preserving source/reference files.
- Make the dataset workflow deterministic in `scripts/download_dataset.py`: expose a small CLI, download through `kagglehub`, copy or link the expected `taxi_log_2008_by_id` directory into a documented project-local raw-data location, and fail with actionable messages when Kaggle credentials/dependencies or the expected files are missing.
- Add a lightweight, non-destructive smoke-test script under `scripts/` that checks required tools, verifies/builds the headless executable as appropriate, downloads or detects a small fixture/raw dataset, normalizes one trajectory, runs `simplify`, and validates the canonical output format. Keep the full benchmark explicitly separate because it is long-running and resource-intensive.
- Update `README.md` to reflect the actual CMake targets and paths, distinguish source/reference materials from generated outputs, document the MIT license, and provide a short “Quick Start” with exact commands for dependency installation, data preparation, smoke testing, one-trajectory execution, and the optional full benchmark. Correct all stale script paths and explain what is and is not included in a fresh clone.
- Add concise contributor/reproducibility notes covering platform assumptions, Kaggle access requirements, output locations, cleanup commands, baseline attribution, and how to cite the paper. Avoid adding broad documentation files unless the resulting workflow genuinely needs them.

## Verification
- Run CMake configure/build in a fresh ignored build directory and confirm the documented executable names match the generated targets.
- Run the smoke test against a small trajectory and verify `original.txt` and `simplify.txt` headers/point records.
- Exercise dataset-helper help/error paths without requiring credentials, and validate the documented full-data path where local credentials are available.
- Check README command paths against the filesystem and inspect `git status`/ignore behavior to ensure build, trace, data, and benchmark artifacts remain untracked.

## Key files
- `[README.md](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/README.md)`
- `[.gitignore](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/.gitignore)`
- `[CMakeLists.txt](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/CMakeLists.txt)`
- `[scripts/download_dataset.py](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/scripts/download_dataset.py)`
- `[scripts/benchmark.py](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/scripts/benchmark.py)`
- New `[LICENSE](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/LICENSE)` and smoke-test script under `scripts/`
