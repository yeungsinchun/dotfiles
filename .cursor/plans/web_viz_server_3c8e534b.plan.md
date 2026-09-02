---
name: Web Viz Server
overview: Add a `--web-server` flag to `simplify.cpp` that emits machine-readable JSON trace of every algorithm step, then build a self-contained HTML/JS visualization page that replays it interactively.
todos:
  - id: parse-flag
    content: Add web_server_flag to simplify_io.h and parse --web-server in parse_arguments()
    status: completed
  - id: trace-structs
    content: Define StepTrace and PrefixTrace structs in simplify.cpp to hold per-step F, Gi, new_S, dead, buffer data
    status: completed
  - id: stab-web
    content: Implement get_longest_stab_web() that mirrors get_longest_stab but populates a PrefixTrace at each step
    status: completed
  - id: simplify-web
    content: Implement simplify_web() that runs the prefix loop with get_longest_stab_web, then serializes all traces to JSON stdout
    status: completed
  - id: main-branch
    content: In main(), branch on web_server_flag to call simplify_web() and skip all human-readable output
    status: completed
  - id: frontend
    content: "Create web/index.html: self-contained Canvas-based viewer with file picker, pan/zoom, step controls, and toggle layers"
    status: completed
isProject: false
---

# Web Visualization for Simplification Algorithm

## Output format (stdout when `--web-server`)

A single JSON object is printed at the end, containing everything the frontend needs:

```json
{
  "eps": 0.5,
  "delta": 200,
  "time_ms": 12.34,
  "grid_val": 35.35,
  "r_val": 300.0,
  "bbox": [xmin, ymin, xmax, ymax],
  "stream": [[x,y], ...],
  "simplified": [[x,y], ...],
  "prefixes": [
    {
      "p0": [x, y],
      "P": [[x,y], ...],
      "steps": [
        {
          "stream_idx": 3,
          "pi": [x, y],
          "Gi": [[x,y], ...],
          "candidates": [
            {
              "grid_pt_idx": 0,
              "alive": true,
              "F": [[x,y], ...],
              "new_S": [[x,y], ...]
            }
          ],
          "buffer": [[x,y],[x,y]]
        }
      ],
      "output": [[x,y],[x,y]]
    }
  ]
}
```

Each `prefix` = one call to `get_longest_stab`. Each `step` = one iteration consuming `stream[cur]`. The `S` state is implicit: `S[i]` after step `k` is `new_S[i]` from that step (skip dead candidates). Initial `S[i] = [P[i]]` before any steps.

## C++ changes — [`simplify.cpp`](simplify.cpp)

1. Add `inline bool web_server_flag = false;` to [`simplify_io.h`](simplify_io.h) and parse `--web-server` in `parse_arguments`.

2. Add a new `get_longest_stab_web` in `simplify.cpp` (or a templated/flag variant) that collects a `PrefixTrace` struct at each step and populates it with `P`, `Gi`, `F[i]`, `new_S[i]`, `buffer`, and `dead` state.

3. Add `simplify_web()` that calls `get_longest_stab_web` in a loop, then serializes all `PrefixTrace` objects to JSON via a hand-rolled (no-dependency) JSON writer and prints to stdout.

4. In `main()`, branch on `web_server_flag`: call `simplify_web()` instead of `simplify()`, suppress all human-readable `cout` output.

Key geometry values to emit per prefix:
- `GRID_val(EPSILON, DELTA)` — grid spacing
- `R_val(EPSILON, DELTA)` — disk radius
- `BMIN`/`BMAX` — bounding box
- `P` — grid candidate anchor points
- Per step: `Gi` convex hull, `F[i]` wedge polygon, `new_S[i]` intersection polygon, alive/dead status, `buffer` (current best segment)

## Frontend — `web/index.html`

A single self-contained HTML file (no build step, no npm). Stack: HTML + vanilla JS + [Canvas API](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API).

### Layout

```
┌─────────────────────────────────────────────────────┐
│  Load JSON  [file picker / paste]   Params display  │
├──────────────────┬──────────────────────────────────┤
│                  │  Timeline scrubber               │
│   Canvas         │  Prefix: [◀ 1/5 ▶]              │
│   (pan+zoom)     │  Step:   [◀ 3/12 ▶]             │
│                  │  ─────────────────────────────── │
│                  │  Legend (color-coded):           │
│                  │    stream pts / simplified /     │
│                  │    P anchors / Gi / F / S        │
└──────────────────┴──────────────────────────────────┘
```

### Interactive features
- Load JSON: file picker or drag-and-drop
- Pan (drag) + zoom (scroll wheel) on canvas
- Step through with prev/next buttons or keyboard (←/→ for steps, shift+←/→ for prefixes)
- Toggle visibility of: stream, simplified, P points, Gi polygon, F wedge, new_S intersection, dead candidates, buffer segment
- Auto-fit view on load
- Show current `stream_idx`, alive candidate count, `buffer` endpoint coords in a status bar

### Rendering layers (draw order)
1. Bbox rectangle
2. Full stream (gray polyline)
3. Gi convex hull (yellow fill, per current step)
4. F wedge polygons for each alive candidate (blue tint)
5. new_S intersection polygons (green tint)
6. Dead candidate anchors (red X)
7. Alive candidate anchors P (orange dots)
8. Buffer segment (thick magenta line)
9. p0 anchor (large dot)
10. pi current point (circle highlight)
11. Simplified output so far (thick green polyline)

## Files to create/modify

- [`simplify.cpp`](simplify.cpp) — add `--web-server` branch + `simplify_web()` + `get_longest_stab_web()`
- [`simplify_io.h`](simplify_io.h) — add `web_server_flag` global + parse `--web-server`
- `web/index.html` — new self-contained frontend (no build step)

## Usage

```bash
# Build (unchanged)
cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j

# Generate trace
./build/simplify --in 1 -e 0.5 -d 200 --web-server > trace.json

# Open locally
open web/index.html   # load trace.json via file picker
```
