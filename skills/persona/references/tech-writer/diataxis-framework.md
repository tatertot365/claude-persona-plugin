# Diátaxis Documentation Framework — Quick Reference

Diátaxis is a framework for structuring technical documentation around user needs. It defines four distinct document types organized along two axes:

- **Axis 1:** Learning vs. Doing
- **Axis 2:** Practical (applied) vs. Theoretical (conceptual)

```
              LEARNING
                 |
    Tutorial     |    Explanation
                 |
PRACTICAL -------|--------- THEORETICAL
                 |
    How-To       |    Reference
                 |
               DOING
```

Each quadrant serves a different user in a different moment. Mixing them creates documentation that serves no one well.

---

## The Four Quadrants

### Tutorial
**Orientation:** Learning-oriented. Practical.
**The user is:** A newcomer who wants to get started and build confidence.
**The goal:** Successfully complete a guided exercise and feel that working with the tool is achievable.

A tutorial is a **lesson**. The writer holds the learner's hand through a complete, concrete experience. The learner does not yet know what they need — the writer decides.

**How to write one:**
- Start with a working environment. Don't ask learners to configure anything complex before the first win.
- Structure as a sequence of numbered steps. Every step produces a visible result.
- Use a realistic but safe example (a to-do app, a sample dataset, a toy service).
- Explain what the learner is doing at each step, not why the software works that way. Save the "why" for Explanation docs.
- End with a fully working outcome. The learner should finish with something they made.
- Keep it completable in one sitting (15–60 minutes).

**What makes it fail:**
- Too much theory before the first action ("Before we begin, let's understand the architecture…")
- Steps that can fail without telling the learner what to do when they fail
- Assuming knowledge that a newcomer wouldn't have
- Letting it grow into a comprehensive guide — tutorials should be focused, not exhaustive
- No defined end state — learner doesn't know when they're done

---

### How-To Guide
**Orientation:** Doing-oriented. Practical.
**The user is:** Someone with a specific task to accomplish. They already know the basics.
**The goal:** Successfully complete a real-world task.

A how-to guide is a **recipe**. It addresses a specific goal ("How do I authenticate with OAuth 2.0?", "How do I export data as CSV?"). It assumes the reader already knows what they're doing in general; they just need the steps for this particular task.

**How to write one:**
- Title it as a goal: "How to configure HTTPS", "How to migrate from v1 to v2".
- Start with a one-sentence statement of what the guide achieves.
- List any prerequisites at the top (the reader should already know X, have Y installed).
- Give steps in order. Be concise — the reader doesn't need hand-holding.
- Show the expected result for key steps so the reader can verify they're on track.
- Do not explain why the software works this way. Link to Reference or Explanation for that.
- A single guide should address a single task. If it branches heavily ("if you're on Linux, do this; if on macOS, do that"), consider splitting.

**What makes it fail:**
- Too much explanation of concepts (that belongs in Explanation)
- Steps that are too granular for someone who already knows the basics
- Starting from scratch instead of assuming prerequisites (that's a Tutorial)
- Incomplete — stops before the task is fully done
- Trying to cover every variation ("depending on your use case…") — address the most common case, link to others

---

### Reference
**Orientation:** Doing-oriented. Theoretical.
**The user is:** Someone who already knows what they're doing and needs to look something up.
**The goal:** Find an accurate, complete, specific piece of information quickly.

Reference is an **encyclopedia entry**. It describes the software as it is, not as it's used. The reader arrives knowing what they're looking for.

**How to write one:**
- Organize around the structure of the software, not around user tasks.
- Be consistent and predictable. Every function, every config key, every CLI flag should follow the same pattern.
- Be complete. Every parameter, return type, error condition, and constraint must be documented.
- Be precise. Avoid adjectives like "fast" or "simple." Stick to what is factually true.
- Do not include tutorials or usage stories. A sentence like "Here's a typical workflow…" does not belong here.
- Keep it neutral — describe behavior, not guidance.

**What makes it fail:**
- Tutorial-style "getting started" paragraphs at the top of API docs
- Inconsistency — some parameters explained in depth, others with a single vague sentence
- Missing edge cases, error conditions, or constraints
- Opinions and recommendations mixed in with factual descriptions
- Outdated content that hasn't been updated to match the current software

---

### Explanation
**Orientation:** Learning-oriented. Theoretical.
**The user is:** Someone who wants to understand why — not to accomplish a task right now, but to build a mental model.
**The goal:** Deepen understanding of a concept, design decision, or system.

Explanation is a **discussion**. It provides background, context, and reasoning. It answers questions like "Why is it designed this way?", "What are the tradeoffs between approaches X and Y?", "How does the authentication system actually work?"

**How to write one:**
- Open with the question or concept being addressed.
- Provide context and history where relevant ("This was designed before async I/O was common…").
- Discuss alternatives and tradeoffs — explanation docs are allowed to say "this approach has downsides."
- Use analogies and diagrams where they help build intuition.
- Do not include step-by-step instructions (that's a How-To) or exhaustive detail (that's Reference).
- Link to the Reference and How-To docs that apply the concepts explained here.

**What makes it fail:**
- Disguising an explanation as a tutorial by adding artificial "exercises"
- Being so abstract it never connects to the actual software
- Mixing in step-by-step how-to instructions
- Being so opinionated it reads as advocacy rather than explanation
- No clear focus — "everything about the authentication system" is too broad

---

## Decision Guide

Use this table when deciding what type of document to write.

| If the reader wants to... | Write a... |
|---------------------------|------------|
| Learn by doing for the first time | Tutorial |
| Build confidence with a new tool | Tutorial |
| Accomplish a specific task | How-To Guide |
| Solve a particular problem they've encountered | How-To Guide |
| Look up a specific function, flag, or config value | Reference |
| Check the exact parameters for an API call | Reference |
| Understand why something works the way it does | Explanation |
| Understand the tradeoffs between two approaches | Explanation |
| Get background on a concept before using it | Explanation |
| Know what changed in a migration | How-To Guide (migration guide) |
| Know all the options available to them | Reference |

---

## Common Mistakes

### Putting Tutorial Content in Reference Docs
Reference docs often grow "Getting Started" sections that walk the reader through a workflow. This confuses the reader who came to look something up and makes the reference harder to scan. Move getting-started content to a dedicated Tutorial.

**Sign:** Your API reference has paragraphs like "To get started, first create a client. Here's how you would typically use it…"

### Writing How-To Guides That Are Actually Tutorials
A how-to guide that starts with "First, install the tool" and assumes zero prior knowledge is a Tutorial. A How-To guide starts after the reader already knows the basics.

**Sign:** Your "How to Deploy to Production" guide begins with "What is a server?"

### Mixing Explanation Into How-To Guides
Adding background theory to a task-oriented guide bloats it and slows down the reader who just wants the steps. Put the theory in an Explanation doc and link to it.

**Sign:** Your how-to guide has multi-paragraph sections titled "Background" or "How This Works."

### Writing Reference Docs With Tutorial Tone
Reference docs should not say "You'll want to use this when…" or "A great option is to try…" That's guidance, not description.

**Sign:** Your reference contains recommendations, tips, or first-person framing.

### Creating One Giant "Everything" Doc
A common shortcut is to write a single long document that mixes tutorial steps, how-to instructions, concept explanations, and parameter tables. This satisfies no reader well — each quadrant has a different reader in a different mode.

**Sign:** Your documentation has sections called "Overview", "Getting Started", "Usage", "Advanced", and "API Reference" all in one file.

### Treating Diátaxis as a Rigid Rule
Diátaxis describes what users need, not an organizational mandate. Some small utilities genuinely need only a README with a tutorial and a reference section. Apply the framework as a diagnostic tool: if users are confused, ask which quadrant is missing or blended incorrectly.
