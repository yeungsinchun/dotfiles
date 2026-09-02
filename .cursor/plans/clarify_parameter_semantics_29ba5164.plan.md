---
name: Clarify Parameter Semantics
overview: Document the distinction between the implementation’s correct epsilon/delta roles and the benchmark’s invalid large-epsilon experiment, then decide whether benchmark parameterization should be corrected.
todos:
  - id: verify-parameter-roles
    content: Confirm simplify.cpp formulas against journal.pdf definitions and theorem assumptions
    status: pending
  - id: separate-benchmark-issue
    content: Identify benchmark parameter choices that violate or reinterpret the paper's epsilon range
    status: pending
  - id: choose-followup
    content: Decide whether to change only benchmark experiments or also add parameter validation to the executable
    status: pending
isProject: false
---

# Clarify Parameter Semantics

- Treat `simplify.cpp` and `simplify_geometry.h` as the reference implementation: `GRID_val` uses `epsilon * delta`, and `R_val` uses `(1 + epsilon / 2) * delta`, matching the journal’s definitions of grid spacing and ball radius.
- Treat the benchmark calls in `scripts/benchmark.py` and `scripts/benchmark_e.py` as the likely source of the inversion concern: they use epsilon values greater than 1 and/or derive epsilon from a Fréchet distance while setting delta to 1, outside the paper’s stated [1mε ∈ (0, 1)[0m regime.
- If implementation changes are requested, revise the benchmark so `delta` represents the intended absolute error tolerance and `epsilon` remains a small approximation parameter; update labels, comments, and result interpretation together.
- Preserve `simplify.cpp` unless a direct algorithmic discrepancy is found, because its parameter formulas currently align with journal.pdf Sections 2 and 2.1.
