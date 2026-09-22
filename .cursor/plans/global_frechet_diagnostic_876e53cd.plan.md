---
name: Global Frechet Diagnostic
overview: Replace the function-local static accessor with an explicit global squared-distance diagnostic, preserving the current measured grid-bound calculation rather than replacing it with `(1 + EPSILON) * DELTA`. Apply the same change to both CLI and GUI implementations.
todos:
  - id: replace-cli-accessor
    content: Replace accessor with global diagnostic in simplify.cpp
    status: completed
  - id: replace-gui-accessor
    content: Mirror global diagnostic in simplify_with_gui.cpp
    status: completed
  - id: verify-build
    content: Check lints and build affected targets
    status: completed
isProject: false
---

# Global Fréchet Diagnostic

- In [`simplify.cpp`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/simplify.cpp), replace `expected_frechet_ref()` with a file-scope `double expected_frechet_squared = 0.0` near the existing global parameters.
- Update the grid construction to accumulate `std::max(expected_frechet_squared, diagonal_sq)`, retaining the observed squared value from the generated boundary cells.
- Update the final diagnostic to print `std::sqrt(expected_frechet_squared)`. This intentionally does not substitute `(1 + EPSILON) * DELTA`, so discrepancies in the actual construction remain visible.
- Mirror the storage and call-site changes in [`simplify_with_gui.cpp`](/Users/sinchunyeung/Simplification-of-Trajectory-Streams/simplify_with_gui.cpp) to prevent the CLI and GUI implementations from diverging.
- Build the affected targets and check diagnostics for both edited files.