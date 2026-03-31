# Product Prioritization Frameworks

Quick reference for scoring and ranking product work. Each framework has strengths and failure modes — match the framework to the situation, not the other way around.

---

## RICE

### Formula

```
RICE Score = (Reach × Impact × Confidence) / Effort
```

| Component | Definition | Typical Scale |
|-----------|-----------|---------------|
| **Reach** | How many users affected per time period (e.g., per quarter) | Raw number (e.g., 500 users/quarter) |
| **Impact** | How much does this move the needle per user | 3 = massive, 2 = high, 1 = medium, 0.5 = low, 0.25 = minimal |
| **Confidence** | How certain are you in your estimates | 100% = high, 80% = medium, 50% = low |
| **Effort** | Total person-months to design, build, and ship | Raw number (e.g., 2 person-months) |

### Scoring Guide

- **Reach**: Use data. Active users per week, # of support tickets, survey respondents — whatever matches your time period. Be consistent across items.
- **Impact**: Use the fixed multiplier scale above. Resist the urge to invent values like 1.7.
- **Confidence**: If you have user research, use 100%. If you're extrapolating, use 80%. If it's a gut feeling, use 50%.
- **Effort**: Sum across all disciplines (eng, design, data). 1 person-month = one person working full-time for one month.

### Worked Example

Feature: In-app onboarding checklist

| Component | Value | Notes |
|-----------|-------|-------|
| Reach | 800 | 800 new users/quarter hit the point where they churn |
| Impact | 2 | High — direct effect on activation rate |
| Confidence | 80% (0.8) | Based on qualitative interviews, no A/B data yet |
| Effort | 3 | 2 eng-months + 0.5 design + 0.5 PM |

**RICE Score = (800 × 2 × 0.8) / 3 = 1,280 / 3 = 426.7**

Compare this score against other candidates. A score of 426 means nothing in isolation — only relative to your backlog.

### When RICE Breaks Down

- **Estimating reach is hard**: For new features (no existing users), reach is speculative. Treat these scores with extra skepticism.
- **Impact scale is coarse**: A 4x difference between "massive" (3) and "low" (0.5) can dominate the calculation, burying real signal.
- **Effort is systematically underestimated**: Teams consistently undercount QA, edge cases, and post-launch fixes.
- **Dependencies are invisible**: Two items may share 70% of the same engineering work. RICE scores both independently, ignoring the combined cost.
- **Not useful for strategic bets**: RICE optimizes for incremental value. Exploratory R&D or platform work scores poorly even when necessary.

---

## ICE

### Formula

```
ICE Score = Impact × Confidence × Ease
```

| Component | Definition | Scale |
|-----------|-----------|-------|
| **Impact** | How much will this move the target metric if it works | 1–10 |
| **Confidence** | How confident are you that it will have that impact | 1–10 |
| **Ease** | How easy is it to implement | 1–10 (10 = trivial, 1 = very hard) |

### Worked Example

Feature: Add keyboard shortcuts to the dashboard

| Component | Score | Notes |
|-----------|-------|-------|
| Impact | 4 | Helps power users but small % of base |
| Confidence | 8 | Power users have explicitly asked for this |
| Ease | 9 | Library support exists; no backend changes |

**ICE Score = 4 × 8 × 9 = 288**

### How ICE Differs from RICE

| Dimension | RICE | ICE |
|-----------|------|-----|
| Reach | Explicit input | Baked into Impact estimate |
| Effort | Denominator (divides) | Replaced by Ease (multiplied) |
| Scale | Uses real numbers for Reach | All 1–10 subjective scores |
| Best for | Teams with usage data | Early-stage, rapid triage |
| Bias risk | Underweighted reach for new features | Ease score inflates "quick wins" |

ICE is faster to run but more vulnerable to bias. Use it for rapid stack-ranking when you lack data or need a quick gut-check. Upgrade to RICE when you have real usage numbers.

---

## MoSCoW

### Definitions

| Category | Meaning | Test to apply |
|----------|---------|--------------|
| **Must Have** | Required for launch; absence makes the product unusable or non-compliant | "Will we ship without this?" — If no, it's a Must |
| **Should Have** | High value; expected by users; painful to omit but not a blocker | "Would a reasonable user be disappointed if this wasn't there?" |
| **Could Have** | Nice to have; adds polish or convenience; dropped first when time is short | "Would most users even notice if this was missing?" |
| **Won't Have (this time)** | Explicitly out of scope for this cycle; may be revisited | "Are we agreeing NOT to do this now?" |

### Common Mistakes

1. **Too many Musts**: If everything is a Must, nothing is. Limit Musts to features that genuinely block shipping.
2. **Won't = never**: Won't Have does not mean rejected forever. It means "not this sprint/quarter." Communicate this clearly to stakeholders.
3. **Skipping the Won't column**: Explicitly listing what you're not doing prevents scope creep and manages expectations.
4. **No shared definition of "launch"**: Musts depend on what launch means. A beta launch and a GA launch have different bars.

### When to Use MoSCoW vs Scoring Frameworks

| Use MoSCoW when... | Use RICE/ICE when... |
|-------------------|----------------------|
| Scoping a specific release or sprint | Comparing items across a full backlog |
| Aligning stakeholders on what's in/out | Explaining prioritization decisions with data |
| Requirements are largely known | You need to surface non-obvious winners |
| Time-boxing is the primary constraint | You want to balance reach, impact, and cost |

---

## When to Use Each Framework

| Situation | Recommended Framework | Why |
|-----------|-----------------------|-----|
| Early-stage startup, thin data | ICE | Fast, opinionated, no data required |
| Growth-stage with usage metrics | RICE | Leverages real reach/effort data |
| Sprint or release scoping | MoSCoW | Aligns team on what ships now |
| Stakeholder alignment meeting | MoSCoW | Concrete, non-mathematical, intuitive |
| Quarterly roadmap planning | RICE | Forces effort/reach tradeoffs |
| Rapid idea triage (> 20 ideas) | ICE | Quick to score, easy to sort |

---

## Common Mistakes Across All Frameworks

### Gaming Scores
Scores are only as honest as the inputs. When scores become a performance metric, teams inflate Impact and Confidence, deflate Effort, and shrink Reach estimates for competitors' favorite features. Mitigate by calibrating scores as a group, not individually, and by reviewing outliers aloud.

### False Precision
A RICE score of 426.7 feels precise. It isn't. The inputs are estimates; the output is a rough ordering tool. Never present a RICE score as though it has more than ordinal meaning. The question to ask is: "Does this rank higher or lower than the other items?" not "Is this score accurate?"

### Ignoring Dependencies
Frameworks treat each item as independent. In practice, Feature B may require infrastructure built for Feature A. Scoring them separately will overstate the cost of B (if A is already planned) or understate the combined effort (if A isn't). After scoring, overlay a dependency map. Items that unlock multiple downstream features earn a structural bonus that no formula captures.
