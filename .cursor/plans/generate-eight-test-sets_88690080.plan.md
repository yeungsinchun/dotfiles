---
name: generate-eight-test-sets
overview: Create Sets 3–10 as eight challenging, original F.1 mathematics papers with matching marking schemes, using the existing LaTeX structure and calibrated against Set 1’s 62-mark, 40-minute standard.
todos:
  - id: scaffold-sets
    content: Create Set 3–10 LaTeX folder structures from the proven Set 2 template.
    status: completed
  - id: author-questions
    content: Write distinct challenging questions for all eight sets using the per-question format blueprint.
    status: completed
  - id: author-marking
    content: Produce checked marking schemes with correct 62-mark allocations for every set.
    status: completed
  - id: compile-verify
    content: Compile all 16 PDFs and fix LaTeX or formatting errors.
    status: completed
isProject: false
---

# Generate Sets 3–10

## Scope and standards
- Create folders `mock/F1/first-test/3` through `mock/F1/first-test/10`, each containing the same question-paper and marking-scheme structure used by Sets 1–2.
- Preserve the 9-question, 62-mark, 40-minute format and existing cover, header, footer, marks-table, and marking-scheme layout.
- Draw on the referenced Pearson question banks and challenging exercises for *problem formats and topic coverage only*; write all questions, values, contexts, and solutions independently.

## Paper blueprint
- Retain the topic coverage in every paper:
  - Q1 arithmetic operations
  - Q2 and Q8 directed numbers
  - Q3 algebraic language / simplification / formula use
  - Q4 and Q9 sequences
  - Q5 divisibility
  - Q6 and Q7 HCF/LCM and applications
- Use a different primary problem format at each question number across Sets 1–10 where feasible. For example, vary Q2 between number-line interpretation, time zones, altitude, profits/losses, score systems, temperature changes, and directed-distance tasks; vary Q6/Q7 between short division, prime factorisation, timetables, packing, tiling, cuboids, and remainder conditions.
- Avoid prompts that refer to unrendered diagrams. Include TikZ figures or number lines whenever a question needs visual information.

## Content and marking schemes
- For each set, write all nine question files in `question-paper/questions/` and the corresponding solution files in `marking-scheme/questions/`.
- Keep mark allocations consistent with the current paper total: Q1 8, Q2 7, Q3 5, Q4 4, Q5 4, Q6 8, Q7 8, Q8 10, Q9 8.
- Verify every numerical answer, explanation, and M/A mark allocation against its question before compiling.

## Validation
- Compile both PDFs for every new set with LaTeX.
- Resolve all compilation errors and content-specific formatting issues, especially nested table/list layout, diagram placement, and page overflow.
- Confirm each question-paper and marking-scheme configuration reports 62 total marks.