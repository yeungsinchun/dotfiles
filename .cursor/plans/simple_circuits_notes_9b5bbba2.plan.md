---
name: Simple Circuits Notes
overview: Draft a LaTeX study notes document adapted from the existing template, covering simple circuits topics (current, voltage, resistance, power, equivalent resistance, emf vs pd, ammeter/voltmeter, potential, resistivity, short circuit) with example-driven explanations using MC problems Q5-Q30 from 4_ch02_MC_e.pdf.
todos: []
isProject: false
---

## Plan: Simple Circuits Study Notes (LaTeX)

### Files to create/modify in `18-7-2026/notes/`

**1. `config.tex`** — Update metadata for physics circuits notes:
- Change PaperYear/Code/SubjLine to physics subject
- Change CoverTitle to "Simple Circuits"
- Change CoverSubtitle to a topic subtitle
- Rewrite CoverInstructions to "How to Use the Notes" (4-5 bullet points on active recall, formulas, working through examples)
- Remove marks-table reference from `main.tex` or leave marks-table empty

**2. `content.tex`** — Structure the notes with these sections:

```
% ============================================================
% content.tex - Simple Circuits Study Notes
% ============================================================

\section{0. The Water Analogy — Your Mental Model for Circuits}
  - Table comparing electric quantities to water system quantities
  - How the water pump = battery, pressure = voltage, flow = current
  - Why this analogy is so powerful: almost all circuit rules have water equivalents

\section{1. Current and Charge}
  - Definition: I = Q/t, unit A (ampere = coulomb per second)
  - Water analogy: flow rate = volume of water per second through a pipe
  - Conventional direction (positive to negative) vs electron flow (opposite)
  - Q = It, total charge transferred
  - Example: Q25 (1.88e18 electrons per second → current calculation)
    % Sol: I = Q/t = (1.88e18 × 1.6e-19)/1 = 0.301 A

\section{2. Voltage, EMF and Potential Difference}
  - EMF (electromotive force): energy supplied by battery per unit charge
    → Water analogy: pump raises water to high pressure — gives water energy
  - PD (potential difference): energy consumed by component per unit charge
    → Water analogy: waterwheel drops water from high to low pressure — uses energy
  - V = W/Q (voltage = work done per unit charge)
  - At an earthed point: potential = 0 (like sea level in water system)
  - Color-coded wires: all points at same potential get the same color label
  - Example: Q29 (12 J energy for 6 C → V = 2 V)
    % Sol: V = W/Q = 12/6 = 2 V
  - Example: Q30 (1 V battery: 0.5 C charge → 0.5 J energy converted)

\section{3. Ohm's Law and Resistance}
  - Ohm's Law: V = IR
    → Water analogy: resistance = narrow pipe — harder to push water through
    → Large R = narrow pipe = little flow for a given pressure
    → Small R = wide pipe = lots of flow for a given pressure
  - Isolate each resistor: draw it alone, label its V and I, then apply V = IR
  - Ohmic device: R = constant → V proportional to I (straight line through origin)
  - Non-ohmic: R changes with temperature/voltage (bulb filament, diode)
  - R = V/I is always true; R = ΔV/ΔI is the slope (only constant for ohmic)
  - Example: Q16 (which statement correctly describes an ohmic device? Answer: I ∝ V)
  - Example: Q13 (which statements about Ohm's law are correct?)

\section{4. Resistivity}
  - R = ρℓ/A — resistivity ρ depends on material, not dimensions
    → Water analogy: pipe material (rough vs smooth) affects how easily water flows
  - Longer wire → more resistance; larger cross-section → less resistance
  - Doubling length doubles R; doubling diameter quarters R
  - Example: Q35 (wire 2l long, 0.5d diameter → R = 80 Ω if original = 10 Ω)
    % Sol: A ∝ d², new A = (0.5d)² = 0.25A, so R new = ρ(2l)/(0.25A) = 8 × (ρl/A) = 80 Ω

\section{5. Equivalent Resistance}
  - ISOLATE and simplify: treat the whole network as one resistor
  - Series: Req = R1 + R2 + ...
    → Same current through each; voltages add; pressure differences stack up
  - Parallel: 1/Req = 1/R1 + 1/R2 + ...
    → Same voltage across each branch; currents add; multiple pipes in parallel
  - For two resistors in parallel: Req = R1R2/(R1+R2)
  - Isolate each branch: draw it separately, find its current or voltage, then combine
  - Example: Q6 (identical resistors, ammeter reads 1 A, find battery current → 2.5 A)
  - Example: Q8 (R1 power = 36 W, all identical, find R2 power → 12 W)
  - Example: Q14-Q15 (ammeter readings in parallel/series circuits)

\section{6. Power in Circuits}
  - P = energy/time = VI = I²R = V²/R
    → Water analogy: power = pressure × flow rate = how fast water does work
  - P = VI: use when V is known (series circuit — same I but different V)
  - P = I²R: use when I is known (series circuit — same I but different R)
  - P = V²/R: use when V is constant across component (parallel)
  - Energy = P × t
  - Example: Q12 (resistance 3R with emf V gives power P; find power with R and 2V → 12P/4 = 3P? No: 12P)
    % Wait: check Q12 solution: P at 3R with V → I = V/3R, P = V²/3R
    % With 2V and R: P' = (2V)²/R = 4V²/R = 12 × (V²/3R) = 12P. Answer: 12P
  - Example: Q21 (power ratio in series: PP:PQ:PR = RP:RQ:RR = 1:2:3)

\section{7. Ammeter and Voltmeter}
  - Ammeter: measures current → connected IN SERIES
    → Water analogy: flow meter placed IN the pipe — must not obstruct flow
    → Ideally r = 0 (like a section of wide open pipe)
    → If connected in parallel: shorts that branch! Never do this.
  - Voltmeter: measures voltage → connected IN PARALLEL
    → Water analogy: pressure gauge tapped across two points — measures difference
    → Ideally r → ∞ (takes no water, like a pressure sensor)
    → If connected in series: breaks the circuit (infinite resistance = gap)
  - Always isolate the meter and ask: what does it measure?
  - Example: Q28 (which shows ammeter properly connected in series?)
  - Example: Q32 (which shows voltmeter properly connected in parallel?)

\section{8. Potential and Potential Difference in Circuits}
  - Electric potential V at a point: potential energy per unit positive charge
    → Water analogy: height/pressure level at a point in the system
  - PD between A and B: work needed to move 1 C from A to B
    → Water analogy: pressure difference between two heights
  - Color-code equipotential wires: all points at same potential share the same color
  - "Hill diagram": height = potential, electron flows downhill (high → low potential)
  - Electron gains energy going through battery (low → high potential)
  - Electron loses energy going through resistor (high → low potential)
  - Isolate two points: the PD between them equals the "height drop" on the hill diagram
  - Example: Q17 (hill diagram: height represents potential energy of positive charges)
  - Example: Q3 (electron greatest energy change = biggest potential drop = largest R)
    % Sol: across largest resistance = biggest voltage drop = biggest energy change

\section{9. Series vs Parallel Circuits — Brightness and Current Distribution}
  - Series: same current everywhere; voltages add; total resistance = sum
    → Water analogy: water flows through one pipe with multiple restrictions — same flow everywhere
  - Parallel: same voltage across each branch; currents add; resistances combine reciprocally
    → Water analogy: water splits across multiple pipes, each sees the full pump pressure
  - Bulb brightness ∝ power dissipated: P = I²R (series) or P = V²/R (parallel)
  - Isolate each bulb: draw only that bulb's branch, label V and I, find its power
  - When one parallel branch opens → total Req increases → other branches get more V → brighter
  - Example: Q22 (which arrangement dims the bulb most? Adding high R in series)
  - Example: Q49 (identical bulbs W, X, Y, Z — brightness comparisons)

\section{10. Short Circuit}
  - Short circuit: zero-resistance path bypasses a component
    → Water analogy: burst pipe — water takes this path instead of the narrow one
  - Current takes the path of least resistance — huge current through the short
  - Battery with short circuit: dangerous — V across battery drops, huge power dissipated
  - In circuit problems: a shorted component is replaced by a wire (R = 0)
  - Open circuit: infinite resistance — no current flows
    → Water analogy: closed valve — no water passes
  - Example: Q37 (voltmeter reading with both switches closed → 0 V if shorted, 6 V if open)
  - Example: Q36 (voltmeter reading with both switches open)

\section{11. Problem-Solving Strategy}
  Step 1: Read the problem — identify what is asked
  Step 2: Draw a water analogy sketch alongside the circuit
  Step 3: Isolate each component — draw it separately with V, I, R labeled
  Step 4: Apply V = IR to each isolated component
  Step 5: Combine — use series/parallel rules to find equivalent resistance
  Step 6: Work backwards — find total current, then distribute to branches
  Step 7: Color-code equipotential points
  Step 8: Check units and reasonableness

\section{12. Quick Reference Formula Sheet}
  - I = Q/t
  - V = W/Q = IR
  - R = ρℓ/A
  - P = VI = I²R = V²/R
  - Req (series) = R1 + R2 + ...
  - Req (parallel) = (1/R1 + 1/R2 + ...)^(-1)
  - Energy = Pt
  - Q = It
```

**3. `main.tex`** — Minor update to reference content properly (already has `\input{content}`)

**4. Keep existing `cover.tex` and `style.tex` unchanged** — cover page format stays the same

**5. Optional: delete or empty `marks-table.tex`** — per instruction to remove marks table

### Design principles for the notes:
- Each concept section starts with definition/formula in a highlighted box
- Followed by 1-2 MC examples (question text + solution)
- Key formulas use `\boxed{}` or bold formatting
- "How to Use the Notes" replaces exam instructions
- Examples drawn from Q5-Q30 of `4_ch02_MC_e.pdf`

### Key pedagogical requirements (NEW):

**A. Water Analogy — used throughout every section:**

A dedicated introductory section explains the analogy, then it is reinforced in every subsequent section:

| Electric System | Water Analogy |
|---|---|
| Battery (EMF) | Water pump — pushes water from low to high pressure |
| Current (I) | Water flow rate — volume per second through a pipe |
| Voltage / Potential Difference (V) | Water pressure difference — between two points |
| Resistance (R) | Narrow pipe / obstruction — resists flow |
| Power (P) | Rate of water doing work — like a waterwheel |
| Charge (Q) | Volume of water — total amount transported |
| Open circuit (gap) | Closed valve — no flow |
| Short circuit (R = 0) | Burst pipe / wide open — huge flow |
| Voltmeter | Pressure gauge — measures pressure difference without obstructing |
| Ammeter | Flow meter — measures flow rate when placed in pipe |

**B. Color-coding of equipotential wires:**
- Every wire at the same potential is colored the same throughout the circuit diagrams
- E.g., all wires connected to the positive terminal of the battery are one color (red), all negative-terminal wires are another color (blue), all earth/ground wires are green
- In circuit diagrams, junctions at the same potential share the same color label
- This makes it visually obvious which points have equal voltage

**C. Isolate every component to apply V = IR:**
- For any resistor or component, always "isolate" it mentally and draw only that component with its voltage and current clearly labeled
- For series components: same current flows through each, voltages add up
- For parallel components: same voltage across each branch, currents add up
- Problem-solving strategy: Draw the isolated component, label V and I, then apply V = IR

**D. Self-contained notes:**
- All essential formulas appear at the start of each section with explanations
- Key concepts are restated in multiple sections when they apply
- The water analogy is consistently reapplied in each new context
- Each example includes the full circuit description so it does not depend on external materials