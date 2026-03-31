# Architecture Decision Record (ADR) Template

An ADR captures a single architectural decision: the context that drove it, what was decided, and what the tradeoffs are. The record should be written at the time the decision is made — not reconstructed later.

---

## Template

```markdown
# ADR-[NNN]: [Short noun-phrase title of the decision]

**Date:** YYYY-MM-DD
**Status:** [Proposed | Accepted | Deprecated | Superseded by ADR-NNN]
**Deciders:** [Names or roles of people involved in the decision]

## Context

[Describe the situation that makes this decision necessary. What problem are you
solving? What forces are in tension — performance vs. simplicity, cost vs.
reliability, speed-to-market vs. correctness? What constraints are non-negotiable
(compliance, team size, existing tech stack)?

This section should be written as if explaining the situation to a new team member
who has no prior context. Aim for 2–5 sentences.]

## Decision

[State the decision clearly and directly. Start with "We will..." or "We have
decided to...". One to two sentences for the decision itself, followed by enough
detail to understand *how* it will be implemented — key mechanisms, patterns, or
boundaries.

Do not bury the decision in caveats. Anyone skimming the document should be able
to read this section alone and understand what was chosen.]

## Considered Alternatives

[List the other options that were seriously evaluated before reaching this decision.
For each, give a one-to-two sentence summary of why it was not chosen. This is
important: it prevents relitigating the decision when someone new joins and asks
"why didn't we just use X?"]

| Alternative | Why rejected |
|-------------|-------------|
| Option A    | Reason      |
| Option B    | Reason      |

## Consequences

**Positive:**
- [What becomes easier, faster, safer, or cheaper as a result of this decision?]

**Negative / Tradeoffs:**
- [What becomes harder, slower, or more expensive? What new obligations does this
  create — operational burden, migration work, future constraints?]

**Risks:**
- [What assumptions is this decision contingent on? What could invalidate it?
  Under what circumstances would this decision need to be revisited?]

## Follow-up Actions

- [ ] [Any immediate tasks created by this decision — ticket links, owners, deadlines]
```

---

## Filled Example

```markdown
# ADR-004: Start with a modular monolith instead of microservices

**Date:** 2024-11-12
**Status:** Accepted
**Deciders:** Tate Gillespie (CTO), Elena Park (Lead Engineer), Ravi Mehta (Staff Eng)

## Context

We are building the first version of a B2B invoicing platform. The team currently
has five engineers, no dedicated DevOps, and a target to reach paying customers in
three months. The domain model is still being discovered — we have changed the
core data model three times in six weeks of prototyping. We need the ability to
iterate quickly and refactor across boundaries without the overhead of distributed
coordination.

Microservices are the default architectural recommendation in our industry, and
several investors have raised the question of whether our "architecture is ready
to scale." The team needs to agree on a deliberate, documented position rather
than drifting into an unexamined approach.

## Decision

We will build a modular monolith: a single deployable unit with strong internal
module boundaries enforced by package/directory structure and a rule against
cross-module imports (enforced in CI). Each module owns its data and exposes a
public API surface to other modules. We will avoid shared database tables across
modules. This positions us to extract services later along existing seams if
and when a specific scaling or team-topology driver requires it.

## Considered Alternatives

| Alternative | Why rejected |
|-------------|-------------|
| Microservices from day one | Premature distribution: network calls, service discovery, distributed tracing, and independent deployment pipelines would consume the majority of engineering capacity before we have validated the product. Domain boundaries are not yet stable enough to cut services correctly. |
| Unstructured monolith (no enforced module boundaries) | Gives us the short-term speed benefit but eliminates the path to future decomposition. Technical debt from a big ball of mud is harder to unwind than a well-seamed monolith. |
| Serverless functions | Vendor lock-in and cold start latency are unacceptable for synchronous invoice-generation flows. Local development and integration testing would be significantly harder. |

## Consequences

**Positive:**
- Engineers can refactor across internal module boundaries without coordinating
  deployments, API versioning, or distributed transactions.
- A single deployment unit means zero infrastructure overhead for now — one
  container, one CI pipeline, straightforward rollback.
- Module boundaries still exist, so the codebase communicates intent and the
  path to extraction is clear when the need arises.

**Negative / Tradeoffs:**
- All modules must be deployed together. A bug in the invoicing module requires
  redeploying the entire application, including the payments module.
- As the team grows past ~15 engineers, parallel work on the same codebase will
  create merge friction. We will need to revisit at that point.
- Enforcing module isolation requires discipline and tooling. A permissive CI
  check or a rushed "just this once" cross-import erodes the architecture
  silently over time.

**Risks:**
- This decision assumes the domain model will stabilize within 6–9 months. If
  the product pivots significantly, module boundaries drawn today may not map
  to the future shape of the system.
- If we hire a large distributed team before extraction is warranted, deployment
  coordination will become a bottleneck. We should reassess at 12 engineers.

## Follow-up Actions

- [x] Add an import-boundary lint rule to CI (PLAT-112, owner: Ravi)
- [ ] Document module ownership in CODEOWNERS (PLAT-118, owner: Elena)
- [ ] Schedule an architecture review at 10 engineers or 12 months, whichever comes first
```

---

## What Makes a Good ADR

### Include

- **The "why," not just the "what."** Anyone can read the code and see what was built. The ADR's only job is to record the reasoning. Describe the forces that made the decision hard.
- **The alternatives you seriously considered.** This is the most commonly omitted section and the most valuable for future readers. Seeing why alternatives were rejected prevents relitigating closed discussions.
- **The real tradeoffs.** Every non-trivial decision has a downside. An ADR that lists only positives is not honest and will not be trusted.
- **The conditions under which this decision should be revisited.** Decisions are made given current constraints. State those constraints explicitly so future engineers know when the ADR has expired.

### Avoid

- **Justifying a decision already made.** An ADR written after the fact to document a foregone conclusion is a paper trail, not a decision record. Write it while the decision is live.
- **Excessive length.** An ADR should fit on one to two printed pages. If it is longer, you are probably covering multiple decisions — split them.
- **Implementation instructions.** An ADR captures *what* and *why*, not *how*. The implementation details live in code, runbooks, and design docs. If you find yourself writing step-by-step instructions, stop.
- **Vague status.** Every ADR must have a status. "Proposed" means it is still under discussion. "Accepted" means it is in effect. "Superseded by ADR-NNN" tells readers where to look for the current thinking. A pile of undated ADRs with no status is worse than no ADRs at all.

### Length and Format

- **Target 300–600 words** for the body (excluding the example and template). Longer is a smell.
- Use a **sequential number** (ADR-001, ADR-002, ...) so decisions can be referenced unambiguously.
- Store ADRs in the repository they affect — typically `docs/adr/` or `architecture/decisions/`. They age best when they live near the code.
- **Never delete an ADR.** Deprecate or supersede it instead. Deleted records leave gaps in the history.
