# Plain Language Checklist — Technical Documentation

Plain language means writing that the intended reader can understand the first time they read it. It is not about dumbing things down; it is about respecting the reader's time.

---

## Word Choice: Substitution Table

Replace inflated or formal words with direct ones. When in doubt, use the shorter word.

| Avoid | Use Instead |
|-------|-------------|
| utilize | use |
| initialize | start, set up |
| leverage | use, apply |
| perform | do, run, carry out |
| terminate | end, stop, close |
| facilitate | help, enable |
| implement | build, add, apply |
| instantiate | create |
| in order to | to |
| prior to | before |
| subsequent to | after |
| in the event that | if |
| at this point in time | now |
| due to the fact that | because |
| it is possible that | might, may |
| make use of | use |
| a large number of | many |
| a majority of | most |
| in close proximity to | near |
| provide an indication of | indicate, show |
| functionality | feature, behavior, capability |
| granularity | detail, level of detail |
| visibility | access, ability to see |
| surface (as a verb) | show, expose, display |
| hydrate (non-data-specific use) | fill, populate |
| spin up | start, launch |
| kick off | start, begin |
| take a dependency on | depend on, require |
| be cognizant of | know, be aware of |
| delineate | define, describe, separate |

**Principle:** If a word has a simpler synonym that means the same thing in context, use the simpler one. Formal vocabulary signals effort; plain vocabulary signals clarity.

---

## Sentence Structure

### Active vs. Passive Voice

**Passive:** "The configuration file is loaded by the server at startup."
**Active:** "The server loads the configuration file at startup."

Active voice is clearer because the actor appears first. Use passive only when the actor is unknown, unimportant, or deliberately omitted.

**Detection test:** If you can append "by zombies" to the sentence and it makes grammatical sense, it's passive.
- "The request was processed [by zombies]." — Passive. Rewrite.
- "The handler processes the request." — Active. No zombies.

### Sentence Length

Aim for an average sentence length of 15–20 words. No sentence should exceed 35 words without a strong reason.

When a sentence exceeds 25 words, ask: Is it doing two things? Split it.

**Before:** "When the user submits the form, the client validates the input locally and, if validation passes, sends an HTTP POST request to the server, which then validates again before persisting the data to the database."

**After:** "When the user submits the form, the client validates the input locally. If validation passes, the client sends a POST request to the server. The server validates again before saving the data."

### When Commas Signal a Split

A sentence with more than two commas often contains two separate ideas. Look for:
- Compound sentences joined by "and" or "but" with a comma — split at the conjunction.
- Parenthetical phrases set off by commas — consider whether the aside can be its own sentence or moved to a note.
- Lists embedded in prose — extract them into a bulleted list.

---

## Jargon Handling

### Define on First Use
The first time you use a technical term, define it inline or link to a definition.

**Example:** "The system uses a content delivery network (CDN) — a distributed group of servers that caches content close to users — to reduce load times."

After the first use, the abbreviation or term alone is fine.

### Acronyms
- Write out the full term on first use, followed by the acronym in parentheses.
- Do not assume your reader knows what an acronym stands for, even if it seems obvious.
- Avoid introducing new acronyms for terms that appear only once or twice.
- If your document uses more than 6–8 acronyms, add a glossary.

### When Jargon Is Appropriate
Jargon is precise vocabulary shared within a field. It is appropriate when:
- You are certain your audience shares it
- The technical term is more precise than plain language alternatives
- You are writing reference documentation for practitioners

When audience is mixed, default to plain language and offer the technical term in parentheses.

---

## Structure Signals

### Bullets vs. Prose

**Use bullets when:**
- Items are genuinely parallel (same type of thing)
- There are 3 or more items
- Order does not matter (if order matters, use a numbered list)
- Each item is short (1–2 lines)

**Use prose when:**
- Items connect causally ("because", "therefore", "however")
- There are only 2 items — prose is clearer: "X and Y" beats a two-item list
- The items tell a story or have a progression

**Warning sign:** Bullets with connective tissue ("First,", "Also,", "Finally,") are prose pretending to be a list. Write them as prose.

### Header Frequency

Use headers to give readers a scannable table of contents. Guidelines:
- Every major topic shift deserves a header.
- Avoid headers that restate what the reader already knows from the section above.
- Do not use headers to label single-sentence sections.
- Use H2 for primary sections, H3 for subsections. Rarely go to H4.
- A section without any text under it (just a sub-header) is a structural problem.

### Progressive Disclosure
Lead with the most important information. Put prerequisites before procedures. Put common cases before edge cases.

Structure each section like an inverted pyramid:
1. The one-sentence summary of what this section covers
2. The main content
3. Edge cases, exceptions, and advanced notes

Readers who only need the summary stop at step 1. Readers who need detail keep going.

---

## Self-Review Checklist

Before publishing, read the document once as a new reader and answer these 10 questions:

1. **Can someone understand the first paragraph without reading anything else first?** If no, add missing context or move the document later in a learning path.

2. **Is every acronym spelled out on first use?** Scan for parenthetical abbreviations — verify each one was introduced before it was used alone.

3. **Does every sentence have a clear actor?** Rewrite passive constructions where the actor is known and relevant.

4. **Is every numbered or bulleted list actually a list?** Check that items are parallel, each item is the same type of thing, and none contain connective tissue that belongs in prose.

5. **Is the document's purpose stated in the first two sentences?** The reader should know immediately whether this document is for them.

6. **Are there any sentences longer than 35 words?** Find them and split them.

7. **Is every technical term either defined inline or linked to a definition?** Run a fresh pair of eyes scan for field-specific vocabulary.

8. **Can each section stand on its own if someone navigates directly to it?** Check that section-level context is not buried in an earlier section.

9. **Does the document end with a clear next step or summary?** The reader should know what to do or where to go when they finish.

10. **Would a reader new to this topic know what to do next after reading this?** If they'd be left confused about their next action, add a "Next Steps" or "Related" section.

---

## Quick Reminders

- **One idea per sentence.** One topic per paragraph.
- **Shorter is better** when the meaning is preserved. Cut filler, not content.
- **Concrete over abstract.** "The server returns a 404 status code" is better than "an appropriate error response is returned."
- **Second person is fine.** "You can configure this by…" is clearer than "the user can configure this by…"
- **Don't bury the action.** The step the reader needs to take should come at the start of a sentence, not the end.
