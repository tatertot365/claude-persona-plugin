# Product Requirements Document (PRD) Template

Use this template for features, significant enhancements, or any work that touches multiple teams. Complete every section before sharing for review. Sections marked with [REQUIRED] must be filled; others can be marked N/A with a brief reason.

---

## Document Header

| Field | Value |
|-------|-------|
| **Feature Name** | |
| **Author** | |
| **Status** | Draft / In Review / Approved / Deprecated |
| **Last Updated** | |
| **Stakeholders** | |
| **Target Quarter** | |

---

## 1. Problem Statement [REQUIRED]

**Instructions:** Describe the problem you are solving, who experiences it, and the evidence that confirms it exists. A good problem statement is specific enough that someone unfamiliar with the domain could understand what is broken and for whom. Avoid solution language — this section should be solvable by multiple approaches. Cite data, support tickets, or research where possible.

**Example:**
> New users who sign up via the mobile app have a 14-day activation rate of 22%, compared to 41% for web sign-ups (Q3 data, n=4,200). Exit interviews (n=18) indicate most mobile users cannot find their first meaningful action after creating an account. The existing onboarding flow was designed for web and has not been adapted for the mobile context.

**Your problem statement:**

_[Who is the user? What is the problem? What evidence confirms it?]_

---

## 2. Goals and Success Metrics [REQUIRED]

**Instructions:** Define what success looks like in measurable terms. Separate leading indicators (signals that appear quickly and predict success) from lagging indicators (the ultimate outcomes you care about). For each metric, state how it will be measured, the current baseline, and the target. Avoid metrics that are easy to move but don't reflect real user value.

**Example:**

| Metric | Type | How Measured | Baseline | Target |
|--------|------|-------------|----------|--------|
| Mobile 14-day activation rate | Lagging | % of new mobile users who complete ≥1 core action within 14 days | 22% | 35% |
| Onboarding step completion rate | Leading | % of users who reach the final onboarding step | 45% | 70% |
| Support tickets: "what do I do first" | Leading | Weekly ticket count tagged #onboarding-lost | 38/week | < 15/week |

**Your goals and metrics:**

_[Add rows to the table above. Aim for 1–2 lagging indicators and 2–3 leading indicators.]_

---

## 3. User Personas [REQUIRED]

**Instructions:** Identify the user segments this feature is primarily built for. For each segment, describe their job-to-be-done (the underlying progress they are trying to make, not just the feature they want), their current workaround, and any constraints that matter for design. If this feature touches multiple personas differently, note how.

**Example:**

**Persona: First-time mobile user (primary)**
- **Description:** Signed up on iOS or Android within the last 7 days; has not completed a core workflow yet.
- **Job-to-be-done:** "When I first open the app after signing up, I need to quickly understand what I can accomplish here so I can decide if it's worth continuing."
- **Current workaround:** Many email the support team asking where to start; others simply abandon.
- **Relevant constraints:** Low context on the product; may not have a desktop session to reference; attention span is short.

**Persona: Returning power user (secondary — must not degrade their experience)**
- **Description:** Uses the app daily; knows the product well.
- **Job-to-be-done:** "Get to my work without friction."
- **Relevant constraint:** An onboarding overlay that reappears or blocks navigation would be deeply frustrating for this group.

**Your personas:**

_[List each segment with their job-to-be-done and any design-relevant constraints.]_

---

## 4. Requirements [REQUIRED]

### 4a. Functional Requirements

**Instructions:** Write requirements as user stories in the format "As a [persona], I want to [action] so that [outcome]." Each story must have explicit acceptance criteria — the conditions a reviewer can test to confirm the story is done. Keep stories small enough to be built and tested independently. Avoid implementation language in the story itself; save that for the acceptance criteria if needed.

---

**Story 1: Onboarding checklist display**

> As a first-time mobile user, I want to see a checklist of my first three actions when I open the app, so that I know what to do next without guessing.

**Acceptance Criteria:**
- [ ] The checklist appears on the home screen for any user who has not completed all three actions, regardless of session count.
- [ ] Each item displays a title, a one-line description, and a CTA button that navigates directly to the relevant screen.
- [ ] Completed items are visually marked as done and remain visible until all three are complete.
- [ ] The checklist is dismissed automatically (not via an X button) once all three items are marked complete.
- [ ] The checklist does not appear for users who completed all three actions before this feature ships (grandfathered out).

---

**Story 2:** _[Add your next story here]_

> As a [persona], I want to [action] so that [outcome].

**Acceptance Criteria:**
- [ ] _[Criterion 1]_
- [ ] _[Criterion 2]_

---

### 4b. Non-Functional Requirements

**Instructions:** Capture requirements that constrain how the system behaves rather than what it does. Common categories: performance, reliability, security, accessibility, and internationalization. Non-functional requirements are often the ones that get cut in crunch — make them explicit so they get scoped properly.

| Category | Requirement |
|----------|-------------|
| **Performance** | Checklist renders within 200ms of the home screen load on a 4G connection (P95). |
| **Accessibility** | All checklist items must be navigable via VoiceOver/TalkBack. CTA buttons must meet WCAG 2.1 AA contrast ratio. |
| **Reliability** | If the checklist state fails to load, the home screen renders normally without the checklist (fail open, not fail closed). |
| **Data / Privacy** | Completion state stored server-side and synced across devices. No new PII collected. |
| **Internationalization** | Checklist content must be localized for all 12 currently supported locales at launch. |

_[Add, remove, or modify rows as appropriate.]_

---

## 5. Out of Scope

**Instructions:** Explicitly list what this PRD does not cover. This section prevents scope creep, manages stakeholder expectations, and helps engineers push back when asked to add "one small thing." Each item should be specific enough that someone can't argue it's implicitly included. Note whether the item is a future consideration or a deliberate exclusion.

**Example:**
- **Personalized checklist items based on user role** — excluded from v1; may be explored in v2 once baseline data is available.
- **Desktop/web parity** — the web onboarding flow is separately maintained and is not changing in this initiative.
- **A/B testing different checklist copy** — out of scope; would require experimentation infrastructure not yet available on mobile.
- **Gamification (badges, progress bars beyond the checklist)** — intentionally excluded to keep v1 simple and measurable.

**Your out of scope list:**

_[List each exclusion with a brief reason.]_

---

## 6. Dependencies and Risks

**Instructions:** List technical dependencies (services, APIs, teams) that must deliver something for this feature to ship, and identify risks that could delay, degrade, or break the feature. For each risk, note the likelihood, potential impact, and mitigation plan. Dependencies with no named owner are a red flag — assign one.

### Dependencies

| Dependency | Owner | What's Needed | Required By |
|------------|-------|---------------|-------------|
| Backend: user event tracking | @data-platform | New `onboarding_step_completed` event schema | 2 weeks before dev start |
| Design system: checklist component | @design-systems | Reviewed and approved checklist UI component | Week 1 of build sprint |

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Localization strings not ready for all 12 locales at launch | Medium | Launch delay or English fallback | Flag to i18n team 6 weeks out; agree on fallback policy now |
| Checklist state sync causes latency on home screen load | Low | Degrades core experience for all users | Implement optimistic loading with local state; hydrate from server asynchronously |

---

## 7. Open Questions

**Instructions:** Capture questions that are unresolved at the time of writing. For each question, note who owns getting an answer and by when. Do not leave open questions in the doc after approval — resolve or explicitly defer them. Unresolved questions at launch are scope ambiguities waiting to surface as bugs.

| # | Question | Owner | Resolution Needed By | Resolution |
|---|----------|-------|----------------------|------------|
| 1 | Do we show the checklist to users who signed up before this feature ships but have not activated? | PM | Before design review | _[Pending]_ |
| 2 | What are the exact three checklist actions — confirmed by data or assumed? | PM + Data | Before writing acceptance criteria | _[Pending]_ |
| 3 | Is the 200ms performance target based on a real SLO or a reasonable guess? | Eng lead | Before dev kickoff | _[Pending]_ |
