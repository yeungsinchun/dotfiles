---
name: Past paper MC database
overview: Build an autonomous vision-driven pipeline that converts scanned DSE Physics MC papers into a structured, retrieval-ready JSON database, using 2012 Paper 1A as a smoke test with its answer key and per-option percentages.
todos: []
isProject: false
---

# Past Paper MC Database - Autonomous Extraction Pipeline

## Goal
Turn scanned, image-only DSE Physics MC PDFs into a clean, topic-searchable JSON database. Smoke test on [Year/MC/2012p1a.pdf](Year/MC/2012p1a.pdf) + [Year/Answer/2012ans.pdf](Year/Answer/2012ans.pdf) only.

## What the research established
- Both PDFs are **pure scanned images**: one embedded PNG per page at 6976x4916, landscape pages `rot=90` (display portrait), only a `"Provided by dse.life"` watermark as text. No extractable text layer -> vision/OCR required.
- Local tooling available: `pymupdf (fitz)`, `PIL`, `tesseract`, `pdftoppm`, `pdfinfo`.
- [work/manual_crops.json](work/manual_crops.json) is a prior *manual* crop attempt (hand-tuned pixel boxes for Q1-Q33). We will **not** rely on it; the new system is autonomous. It only serves as a rough sanity reference for question count/order.
- Decisions confirmed: extraction engine = **agent vision** (I read rendered page images and emit JSON, no external API/keys); non-text content = **crop to PNG + text/LaTeX description** (retrieval on text, original image preserved).

## Directory / output layout
```
work/
  pages/2012p1a/            # rendered upright full-page PNGs (page-000.png ...)
  pages/2012ans/
  figures/2012p1a/          # cropped figures/option-graphs/tables (q07_fig1.png ...)
  2012p1a.json              # final structured database for this paper
  build_pages.py            # step 1 renderer
  crop_figure.py            # helper: crop bbox from a page -> figures/
```

## Pipeline (autonomous, repeatable)

### Step 1 - Render pages (script)
`build_pages.py` uses `fitz` to open each PDF, apply page rotation so content is **upright**, render at ~200-300 DPI (`Matrix(zoom)`), and save `work/pages/<stem>/page-NNN.png`. Handles per-PDF variation (cover pages, booklet order, differing page counts) by rendering *all* pages; downstream vision step decides which pages hold questions vs cover/instructions.

### Step 2 - Vision transcription of question pages (agent loop)
For each rendered question page I read the PNG and produce structured records:
- Detect question number(s) on the page and their vertical span.
- Transcribe stem text; math as LaTeX.
- Classify **option format** per question (see schema `option_type`): `text`, `math`, `graph`, `diagram`, `table`, `mixed`.
- Flag any figure/table in the stem or options that must be cropped, giving a normalized bbox `[x0,y0,x1,y1]`.

### Step 3 - Crop non-text content (script + verify)
`crop_figure.py` takes page + normalized bbox -> writes PNG to `work/figures/...`. I then read each crop back to (a) verify it captured the right region (auto-retry with adjusted bbox if not) and (b) write a short text description into the record. This satisfies "crop_and_describe".

### Step 4 - Parse answers + statistics (agent vision on answer PDF)
Render [Year/Answer/2012ans.pdf](Year/Answer/2012ans.pdf) pages (Step 1 already covers it) and read them. DSE dse.life answer sheets list, per question: the **correct option** and the **percentage of candidates choosing each option** (A/B/C/D). Extract both. If a page turns out to only have the key without percentages, capture whatever is present and record `stats: null` for missing ones. Merge into each question record by question number.

### Step 5 - Emit final JSON + validation
Assemble `work/2012p1a.json`, then validate: sequential question numbers with no gaps, every question has `answer`, every `option_type != text` question has either a crop or table data, and answer-key count matches question count. Report any mismatches.

## Proposed JSON schema (tailored to MC formats)
```json
{
  "paper": {
    "id": "2012p1a",
    "subject": "Physics",
    "exam": "HKDSE",
    "year": 2012,
    "paper": "1A",
    "type": "MC",
    "source_pdf": "Year/MC/2012p1a.pdf",
    "answer_pdf": "Year/Answer/2012ans.pdf",
    "num_questions": 0
  },
  "questions": [
    {
      "number": 7,
      "topic": null,
      "stem_text": "A ball is projected ... find its speed.",
      "stem_latex": "v = \\sqrt{2gh}",
      "stem_figures": [
        {"image": "work/figures/2012p1a/q07_fig1.png",
         "description": "Velocity-time graph, linear rise from 0 to 5 s",
         "page": 9, "bbox": [0.12,0.20,0.55,0.48]}
      ],
      "option_type": "graph",
      "options": [
        {"label": "A", "text": null, "latex": null,
         "image": "work/figures/2012p1a/q07_optA.png",
         "description": "straight line through origin, positive slope",
         "percentage": 12.3},
        {"label": "B", "text": "...", "percentage": 5.1},
        {"label": "C", "text": "...", "percentage": 70.4},
        {"label": "D", "text": "...", "percentage": 12.2}
      ],
      "answer": "C",
      "source": {"paper_page": 9, "bbox": [0.0,0.05,1.0,0.42]}
    }
  ]
}
```
Notes on tailoring:
- `option_type=table` -> add `option_table` (rows/cols as arrays) instead of/alongside crops.
- `option_type=diagram|graph` -> each option gets its own `image` + `description`.
- `option_type=text|math` -> `text`/`latex` populated, no image.
- `stem_figures` is a list (0..n) so table-in-stem or multi-figure questions are covered.
- Every option carries `percentage` from the answer sheet; `answer` holds the correct label.

## Retrieval-readiness (for later, not built now)
Schema keeps a flat `questions[]` with rich text (`stem_text`, `stem_latex`, option/figure `description`s) so a later step can concatenate these into an embedding document per question and store `topic` (topics list exists under [Topic/](Topic/)). No DB is built in this task; JSON is the handoff artifact.

## Scope guardrails
- Only 2012 Paper 1A + 2012 answers are processed in this task (smoke test). The scripts are written generically so other years/papers can be run later by changing the input path, but I will not run them here.
- No external network/API; all vision transcription is done by me directly.