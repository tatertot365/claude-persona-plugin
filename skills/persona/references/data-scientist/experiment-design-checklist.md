# A/B Test & Experiment Design Checklist

A systematic checklist for running valid, interpretable experiments. Work through each phase in order — skipping pre-experiment steps is the most common source of bad results.

---

## Phase 1: Pre-Experiment

### Define the Hypothesis Clearly

- [ ] Write a specific, falsifiable hypothesis: "Changing [X] will increase [metric] by [expected magnitude] because [mechanism]."
  - Bad: "The new button color will help."
  - Good: "Changing the CTA button from gray to orange will increase checkout click-through rate because it improves visual salience on mobile."
- [ ] Identify the **primary metric** — the single metric the test is designed to move. Tests with multiple primary metrics require multiple corrections.
- [ ] Identify **guardrail metrics** — metrics that must not degrade (e.g., revenue per session, error rate, latency). Define acceptable bounds before the test runs.
- [ ] Define what "winning" looks like: required statistical significance, minimum effect size, direction.

### Run a Power Analysis

Power analysis determines the sample size needed to reliably detect an effect of a given size.

**Core parameters:**
| Parameter | Typical Value | Notes |
|---|---|---|
| α (significance level) | 0.05 | Probability of a false positive (Type I error) |
| Power (1 − β) | 0.80 | Probability of detecting a true effect (0.80 = 80% chance; 0.90 is more conservative) |
| Minimum Detectable Effect (MDE) | Varies | The smallest effect worth acting on — not the expected effect |
| Baseline conversion rate | Varies | Required for proportions; σ required for continuous metrics |

**Formula for two proportions (e.g., conversion rates):**

For equal group sizes, approximate required n per group:

```
n ≈ (z_α/2 + z_β)² × [p₁(1−p₁) + p₂(1−p₂)] / (p₁ − p₂)²
```

Where z_α/2 = 1.96 (for α = 0.05, two-tailed) and z_β = 0.84 (for 80% power).

**Worked Example:**
- Baseline checkout conversion rate: 5% (p₁ = 0.05)
- Minimum detectable effect: 1 percentage point lift (p₂ = 0.06)
- α = 0.05, Power = 80%

```
n ≈ (1.96 + 0.84)² × [0.05×0.95 + 0.06×0.94] / (0.05 − 0.06)²
  = (2.80)² × [0.0475 + 0.0564] / 0.0001
  = 7.84 × 0.1039 / 0.0001
  = 8,146 per group
```

You need approximately 8,146 users per variant (16,292 total) to detect a 1pp lift with 80% power. If your site gets 500 checkout views per day, this test needs ~33 days to run — before accounting for any weekday/weekend effects.

- [ ] Run power analysis with your actual baseline and MDE **before** starting the experiment
- [ ] Verify that required sample size is achievable within a reasonable timeframe (≤ 4–6 weeks is common practice; longer tests risk external validity problems)

### Randomization Unit Selection

- [ ] Choose the correct randomization unit — the entity that is assigned to a variant:
  - **User-level:** Most common; good for reducing variance; use when the experience persists across sessions
  - **Session-level:** Use only when users are anonymous and session effects don't bleed across sessions
  - **Page/request-level:** High variance, not recommended unless the metric is also per-request
- [ ] Verify that the randomization unit matches the analysis unit (e.g., if randomizing by user, analyze by user — not by page views)
- [ ] Check that randomization is truly random: no time-based skew, no device-type confounding

### Minimum Detectable Effect (MDE) Selection

- [ ] Choose the MDE based on **business significance**, not statistical convenience. Ask: "What is the smallest lift that would change a product decision?"
- [ ] Avoid setting MDE based on what you hope to see — that inflates false positives
- [ ] Document the MDE in writing before running the test

---

## Phase 2: During the Experiment

### Sample Ratio Mismatch (SRM) Check

- [ ] Verify that the observed split between control and treatment matches the expected split
  - Expected 50/50? Check that actual ratio is close to 50/50 using a chi-square test on assignment counts
  - SRM indicates a bug in assignment, logging, or filtering — **results cannot be trusted** until the SRM is resolved
- [ ] Run SRM checks early (after first 1,000–2,000 assignments) and again at midpoint

### Avoiding Peeking

- [ ] **Do not analyze results mid-experiment and make a decision based on significance**. Peeking inflates Type I error dramatically — a test checked daily at α = 0.05 can reach a true false-positive rate of 20–30%.
- [ ] If early stopping is required, use a sequential testing method (e.g., SPRT, always-valid inference, or a pre-registered interim analysis with adjusted α)
- [ ] Set an end date and sample size target before the test starts and respect it

### Segment Consistency Checks

- [ ] Monitor for unexpected segment imbalances (e.g., variant A has 60% mobile users while control is 50%)
- [ ] Watch for instrumentation failures: missing events, null metric values for one variant, client-side vs. server-side logging mismatches

---

## Phase 3: Post-Experiment

### Interpreting Results

- [ ] **Report confidence intervals, not just p-values.** A CI of [+0.2%, +1.8%] is far more informative than p = 0.03. It shows both statistical significance and the range of plausible effect sizes.
- [ ] Distinguish **statistical significance** (the result is unlikely under the null) from **practical significance** (the effect is large enough to matter). A test with n = 500,000 may detect a 0.01% lift as statistically significant — that may not be actionable.
- [ ] Check whether the observed effect size falls within the pre-registered MDE range
- [ ] Examine guardrail metrics: a statistically significant lift in the primary metric with a statistically significant degradation in revenue or latency is not a win

### Novelty Effect Check

- [ ] Consider whether a short-term lift may be driven by novelty (users engage with anything new)
- [ ] If the change is visible/interactive, examine the treatment effect over time: if the lift declines over the test period, novelty may be the cause
- [ ] For features with novelty risk, consider extending the test or re-running after the initial novelty window

### Final Checklist Before Shipping

- [ ] Primary metric moved in the expected direction with p < α
- [ ] Confidence interval excludes 0 and the lower bound is above minimum practical threshold
- [ ] No guardrail metrics were statistically significantly degraded
- [ ] No SRM detected
- [ ] Segment analysis shows consistent direction (even if not all segments are individually significant)
- [ ] Novelty effects considered

---

## Common Mistakes

| Mistake | Why It's a Problem | Fix |
|---|---|---|
| **Underpowered test** | High false negative rate — real effects missed; also, any "significant" result in an underpowered test tends to overestimate effect size (winner's curse) | Run power analysis before starting; use realistic MDE |
| **Peeking at results mid-test** | Inflates Type I error; teams stop tests early when they randomly cross significance | Set end date in advance; use sequential testing if early stopping is needed |
| **Multiple comparisons without correction** | With 20 metrics, expect ~1 false positive at α = 0.05 even with no true effects | Designate one primary metric; apply Bonferroni or FDR correction for secondary metrics |
| **Testing too many variants** | Each additional variant increases the number of pairwise comparisons, increasing Type I error; also dilutes sample size per variant | Test 1–2 variants at a time; use multi-armed bandit only with appropriate corrections |
| **Survivorship / engagement bias** | Analyzing only "active" users after assignment can introduce post-treatment selection bias | Analyze on the full assigned population (intent-to-treat); segment post-hoc only |
| **Ignoring SRM** | Biased assignment means results do not reflect a true random experiment | Check SRM before analyzing; debug and rerun if SRM > ~1% deviation |
