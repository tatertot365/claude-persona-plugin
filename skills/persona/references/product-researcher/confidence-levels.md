# Research Confidence Levels

A framework for labeling the strength of research findings and communicating uncertainty to stakeholders. Consistent confidence labeling prevents over-reliance on weak signals and under-reliance on strong ones.

---

## The Three Confidence Levels

### High Confidence

**Criteria — all or most of the following apply:**
- Finding appears across two or more independent methods (e.g., interviews + usability test + analytics)
- Observed in a sufficiently large sample (n ≥ 15 for qualitative; statistically powered for quantitative)
- Pattern is consistent across participant segments (role, experience level, use case)
- Behavior was directly observed — not inferred from self-report
- Finding replicates across multiple sessions without contradictory evidence

**How to label findings:**
> "We consistently observed..." / "All participants demonstrated..." / "Across methods, we found strong evidence that..."

**How to communicate to stakeholders:**
This finding is reliable enough to act on without additional research. Present it directly as a problem or behavior to design around. No need to qualify heavily.

**What would increase confidence further (if already high):**
At high confidence, additional research may not be necessary — the value shifts to acting on the finding. If it's a major product decision with high stakes, a quantitative study can confirm prevalence.

---

### Medium Confidence

**Criteria — some of the following apply:**
- Single method (e.g., interviews only, or a single survey)
- Small-to-moderate sample (n = 5–14 for qualitative; borderline power for quantitative)
- Pattern is mostly consistent but with 1–2 notable exceptions
- Some inferences were drawn from behavior (observed → interpreted)
- Finding is plausible given context but has not been triangulated

**How to label findings:**
> "We observed a pattern suggesting..." / "Several participants indicated..." / "Our data suggests, though not conclusively, that..."

**How to communicate to stakeholders:**
State the finding, then explicitly name the limitation. Example: "Five out of seven participants struggled with the filter interaction — this is consistent with what we've heard before, but our sample is small and skewed toward power users. Worth validating before a full redesign."

**What would increase confidence:**
- Run a second method (e.g., follow up interviews with an unmoderated test)
- Increase sample size, especially in underrepresented segments
- Check if analytics or existing data corroborates the pattern

---

### Low Confidence

**Criteria — one or more of the following apply:**
- 1–3 participants total
- Single session or single method with no corroboration
- Finding relies heavily on interpretation rather than direct observation
- High variance — participants disagree or patterns are inconsistent
- Participants are not representative of the target population

**How to label findings:**
> "One participant mentioned..." / "Tentatively, we saw a hint of..." / "This is a weak signal that warrants further investigation..."

**How to communicate to stakeholders:**
Be explicit that this is a hypothesis, not a finding. Frame as a direction to explore, not a conclusion. Example: "We heard one participant mention difficulty with X — this is too early to act on, but we recommend including it in the next round of research."

**What would increase confidence:**
- Conduct more sessions on this specific topic
- Move from self-report to behavioral observation
- Run a dedicated study to test this as a hypothesis

---

## Separating Observation from Interpretation

One of the most common ways confidence gets inflated is by blurring what was seen with what it means. Always track which layer a claim sits on.

### The Three Layers

| Layer | Definition | Example |
|---|---|---|
| **Observation** | What was directly seen, heard, or measured — no interpretation | "User clicked the back button after viewing the confirmation screen." |
| **Interpretation** | An inference drawn from observations — explicitly labeled as such | "The user may have been uncertain the action completed, or was looking for more detail." |
| **Recommendation** | An action derived from interpretation | "Consider adding a clearer success state with a summary of what happened." |

### Rules for Labeling

- Never let an interpretation masquerade as an observation. If you say "the user was confused," that's an interpretation — label it. Say instead: "The user paused for 8 seconds, re-read the screen, and said 'wait, did that actually go through?' (observation) — this suggests confusion about whether the action was completed (interpretation)."
- Use hedging language to signal inference: "This suggests...", "This may indicate...", "One explanation is...", "We infer that..."
- In research reports and readout decks, visually separate or explicitly label observations vs. interpretations (e.g., a two-column format, or bracketed [interpretation] labels).

### Why It Matters

Stakeholders often cannot distinguish between "we saw a user do X" and "we think users feel Y." When interpretations are presented as facts, teams make product decisions based on the researcher's guess rather than the data. Explicit labeling forces intellectual honesty and keeps the door open for alternative interpretations.

---

## Quick Reference Card

| Level | Label Phrasing | Stakeholder Communication | Next Step |
|---|---|---|---|
| High | "We consistently observed..." | Act on this | Prioritize and design |
| Medium | "Our data suggests..." | Note limitations, monitor | Validate with second method |
| Low | "One participant mentioned..." | Treat as hypothesis | Include in next research round |
