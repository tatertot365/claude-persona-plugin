# Research Method Selector

A decision guide for choosing the right UX/product research method. Work through the dimensions in order, then use the method lookup table to confirm fit.

---

## Step 1: Generative vs. Evaluative

| | Generative | Evaluative |
|---|---|---|
| **Purpose** | Discover problems, needs, and opportunities; build understanding before building | Assess something that already exists (design, prototype, product, copy) |
| **When to use** | Early in a project; when the problem space is unclear; when assumptions are untested | Mid-to-late in a project; when you have something to test or validate |
| **Example questions** | "What are the biggest pain points in how people manage their finances?" / "How do small business owners currently handle invoicing?" | "Can users find the export function?" / "Which headline drives more sign-ups?" / "Does this onboarding flow create confusion?" |

---

## Step 2: Qualitative vs. Quantitative

| | Qualitative | Quantitative |
|---|---|---|
| **Purpose** | Understand the *why* behind behavior; surface themes and mental models | Measure *how many*, *how often*, *how much*; test statistical significance |
| **Typical sample size** | 5–30 (depth over breadth) | 100–1,000+ depending on effect size and variance |
| **Tradeoffs** | Rich insight; not statistically generalizable; takes longer per participant | Statistically generalizable; can miss the "why"; requires instrument design upfront |
| **Best for** | Hypothesis generation, problem discovery, usability issues | Prioritization, A/B testing, market sizing, benchmarking |
| **Danger zone** | Reporting percentages on n=8 as if representative | Running surveys without qualitative foundation — garbage-in answers |

---

## Step 3: Moderated vs. Unmoderated

| | Moderated | Unmoderated |
|---|---|---|
| **Who is present** | Researcher guides the session live | Participant completes tasks independently; software records |
| **When appropriate** | Complex tasks requiring probing; exploratory research; prototype testing before the design is polished; sensitive topics | Simple, well-defined tasks; need for large sample quickly; concept is clear enough to stand alone |
| **Advantages** | Ability to probe unexpected behavior; can redirect; richer insight | Faster and cheaper at scale; less scheduling friction; reduces moderator influence |
| **Disadvantages** | Slower; moderator bias risk; scheduling overhead | Can't probe; participants may disengage; harder to test rough prototypes |

---

## Method Lookup Table

| Method | When to Use | Typical Sample Size | What It Cannot Answer |
|---|---|---|---|
| **User Interviews** | Generative; understanding mental models, workflows, motivations, pain points; early discovery | 8–15 (until saturation) | How often behavior occurs in the wild; which option performs better; statistical significance |
| **Contextual Inquiry** | Understanding behavior in real context (workplace, home); uncovering workarounds; process mapping | 5–10 | Whether behavior is representative across a population; feature preference |
| **Diary Studies** | Longitudinal behavior over days/weeks; experience tracking (e.g., health app, onboarding journey) | 10–20 | Reasons behind specific micro-interactions; immediate in-session reactions |
| **Moderated Usability Test** | Evaluating flows, prototypes, or live product; probing confusion or breakdowns | 5–8 per round (iterate) | Whether problems affect 10% vs. 40% of users; statistical comparison between designs |
| **Unmoderated Usability Test** | Evaluating clear tasks at scale; benchmarking completion rates and time-on-task | 20–50 per variant | The nuanced "why" behind failures; edge cases that need probing |
| **Surveys** | Measuring attitudes, satisfaction (CSAT, NPS), or prevalence of behaviors at scale | 100–500+ (depends on segmentation needed) | Behavior (vs. self-reported behavior); nuanced emotional context; root cause |
| **A/B Testing** | Evaluating two (or more) variants on a single metric in production with real users | 1,000–50,000+ (run power analysis) | Why a variant won; what users think about it; non-metric-adjacent impact |
| **Card Sorting** | Understanding users' mental models for information architecture; navigation design | 15–30 (open sort); 20–40 (closed sort) | Whether users can find content in an implemented IA; task success rates |
| **Tree Testing** | Evaluating findability in a navigation structure without visual design influence | 30–100 | Why users navigate the way they do; design-layer usability issues |
| **Concept Testing** | Evaluating early-stage ideas, messaging, or value propositions before building | 8–15 (qual) or 100+ (survey-based quant) | Actual behavior with a built product; long-term satisfaction |

---

## Quick Decision Flowchart

```
Do you have something to test?
├── No  → Generative methods (interviews, contextual inquiry, diary study)
└── Yes → Evaluative methods
         │
         Is task complexity high or design rough?
         ├── Yes → Moderated usability test
         └── No  → Unmoderated usability test or A/B test
                   │
                   Need statistical significance?
                   ├── Yes → A/B test (need large traffic volume)
                   └── No  → Unmoderated usability test
```
