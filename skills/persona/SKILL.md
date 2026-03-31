---
name: persona
description: Activate, list, create, edit, delete, or deactivate expert personas that shape how Claude assists you. Spawn a single persona as a sub-agent for a specific task, or run multiple relevant personas in parallel. Invoke with /persona list, /persona <name>, /persona spawn <name> <task>, /persona multi <task>, /persona create, /persona edit <name>, /persona delete <name>, /persona ref <name>, or /persona off.
allowed-tools: Read, Write, Glob, Bash, Agent
---

# Persona Manager

Manage expert personas for Claude. Personas are session-only — they apply for the current conversation and do not persist when the session ends.

Based on `$ARGUMENTS`, perform one of the actions below. If `$ARGUMENTS` is empty or blank, treat it as **"help"**.

---

## `/persona help`

When $ARGUMENTS is **"help"** or empty:

Print a concise usage reference:

```
Persona Manager
───────────────────────────────────────────────
/persona list                        List all available personas
/persona <name>                      Activate a persona for this session
/persona spawn <name> <task>         Run a task using a specific persona as a sub-agent
/persona multi <task>                Run a task across multiple relevant personas in parallel
/persona ref <name>                  Show references for a persona
/persona create                      Create a new persona (guided)
/persona edit <name>                 Edit an existing persona
/persona delete <name>               Delete a persona
/persona off                         Deactivate the current persona
/persona help                        Show this help message

Tip: <name> is fuzzy-matched — "security" finds "security-expert"
```

---

## `/persona ref <name>`

When $ARGUMENTS starts with **"ref"**, extract the name after it.
- If no name was provided (i.e. $ARGUMENTS is exactly "ref"), say: "Which persona's references would you like to see? Usage: `/persona ref <name>`" — then stop.
- Otherwise, normalize the name and resolve the file using the same exact → partial → suggest matching logic as `/persona <name>`. If no match is found, stop.

3. Read the persona file and look for a `**References:**` section.
   - If no References section exists, say: "**<name>** has no references defined." — then stop.

4. Display the references in this format:

```
References for <name>
──────────────────────
• <filename> — <when-to-consult description>
• <filename> — <when-to-consult description>

Use /persona ref <name> load <filename> to load a reference into the current session.
```

5. If $ARGUMENTS contains "load" followed by a filename (e.g. `ref security-expert load owasp-top10.md`):
   - Resolve the full path from the persona's References section matching that filename
   - Read the file and display its full contents under a header: `## Reference: <filename>`
   - Confirm: "Reference loaded into session context."

---

## `/persona list`

When $ARGUMENTS is **"list"**:

1. Use Glob to find all `.md` files in `${CLAUDE_SKILL_DIR}/personas/`
2. Read each file and extract the `# Name` heading and the first paragraph after it
3. Print a clean list in this format, marking the currently active persona with `▶` and **(active)** if one is active in this session:

```
Available Personas
──────────────────
▶ security-expert    — Adversarial security mindset, OWASP, threat modeling  (active)
  debugger           — Systematic root-cause analysis
  ...

Use /persona <name> to activate · /persona off to deactivate · /persona create to add a new one · /persona edit <name> to edit · /persona delete <name> to delete
```

If no persona is currently active, omit the `▶` marker from all entries.

---

## `/persona off`

When $ARGUMENTS is **"off"**, **"deactivate"**, or **"reset"**:

1. Explicitly disregard all prior persona instructions from this conversation. Do not apply any previously activated persona's tone, priorities, expertise framing, or communication style — even if those instructions appeared earlier in the context window.
2. Return fully to default Claude behavior: balanced, general-purpose, no specialist framing.
3. Confirm: "Persona deactivated. Returning to default Claude behavior."
4. **For all subsequent responses in this conversation**, treat yourself as having no active persona.

---

## `/persona create`

When $ARGUMENTS is **"create"**:

1. Prompt the user to describe their persona in a single message using this template:

```
Name: <lowercase-hyphenated, e.g. api-architect>
Role: <one sentence describing the expert role>
Tone: <communication style, e.g. direct, educational, rigorous, warm>
Priorities: <2–3 things this expert always optimizes for>
Expertise: <key domains, tools, or methodologies>
Pitfalls: <common mistakes or anti-patterns this expert watches for>
```

   Tell them all fields are required except Pitfalls (optional).

2. Once the user replies, generate a persona `.md` file using this structure:

```markdown
# <Name>

<One paragraph describing who this expert is, their background, and their default mindset.>

**Priorities:**
- <Priority 1>
- <Priority 2>
- <Priority 3 (optional)>

**How you work:**
- <Behavioral guideline 1>
- <Behavioral guideline 2>
- <...>

**Communication style:**
- <Style guideline 1>
- <Style guideline 2>
- <...>

**Domain expertise:**
- <Domain or tool 1>
- <Domain or tool 2>
- <...>

**Pitfalls you watch for:** *(omit section if none provided)*
- <Anti-pattern or common mistake>
```

   Aim for 30–50 lines. Fewer lines are fine if the persona is well-defined; exceed 50 only if the extra content meaningfully improves specificity.

3. Write it to `${CLAUDE_SKILL_DIR}/personas/<name>.md`

4. Ask: "Activate this persona now?" If yes, proceed as with `/persona <name>`.

---

## `/persona edit <name>`

When $ARGUMENTS starts with **"edit"**, extract the name after it.
- If no name was provided (i.e. $ARGUMENTS is exactly "edit"), say: "Which persona would you like to edit? Usage: `/persona edit <name>`" — then stop.
- Otherwise, normalize the name (lowercase, spaces → hyphens) and resolve the file using the same exact → partial → suggest matching logic as `/persona <name>`. If no match is found, stop.
3. Read the current file and display its contents to the user.
4. Ask: "What would you like to change?" — wait for their response.
5. Apply the requested changes and rewrite the file.
6. Confirm: "Updated **<name>**." and show a brief summary of what changed.
7. If this persona is currently active, re-read and re-apply the updated version immediately.

---

## `/persona delete <name>`

When $ARGUMENTS starts with **"delete"** or **"remove"**, extract the name after it.
- If no name was provided (i.e. $ARGUMENTS is exactly "delete" or "remove"), say: "Which persona would you like to delete? Usage: `/persona delete <name>`" — then stop.
- Otherwise, normalize the name (lowercase, spaces → hyphens) and resolve the file using the same exact → partial → suggest matching logic as `/persona <name>`. If no match is found, stop.
3. Confirm with the user: "Delete persona **<name>**? This cannot be undone. (yes/no)"
4. If confirmed, delete the file using a Bash `rm` command.
5. Confirm: "Persona **<name>** deleted."
6. If this persona was currently active, deactivate it as per `/persona off`.

---

## `/persona spawn <name> <task>`

When $ARGUMENTS starts with **"spawn"**:

1. Remove the leading "spawn" word from $ARGUMENTS. The remaining text has the format `<name> <task>` — the first word is the persona name, everything after it is the task description.
   - If nothing remains after "spawn", say: "Usage: `/persona spawn <name> <task>`" — then stop.
   - If only a name is present with no task, say: "Please provide a task. Usage: `/persona spawn <name> <task>`" — then stop.

2. Extract the persona name (first word) and task (all remaining words).

3. Resolve the persona file using the same exact → partial → suggest matching logic as `/persona <name>`. If no match is found, stop.

4. Read the full persona file content.

5. If the persona file contains a `**References:**` section, read every referenced file listed in it. Collect their contents to bundle into the sub-agent prompt.

6. Launch a sub-agent using the Agent tool with the following prompt structure:

```
You are operating as the following expert persona. Apply this persona fully for all responses.

---
[full persona file content]
---

[If references were loaded, include them here:]
## Reference Materials

### [reference filename 1]
[reference file 1 content]

### [reference filename 2]
[reference file 2 content]

Task:
[task]

Complete the task above from the perspective of this persona. Apply the persona's priorities, communication style, and domain expertise throughout your response. Use the reference materials above where relevant.
```

6. Once the sub-agent returns its result, present it to the user under a labeled header:

```
## [Persona Name] — Sub-agent Result

[result]
```

   Note that the session persona (if one is active) was not affected — it remains unchanged.

---

## `/persona multi <task>`

When $ARGUMENTS starts with **"multi"**:

1. Extract the task — everything after the word "multi".
   - If nothing remains, say: "Please provide a task. Usage: `/persona multi <task>`" — then stop.

2. Glob all `.md` files in `${CLAUDE_SKILL_DIR}/personas/` and read the first paragraph of each to understand what each persona covers.

3. Select 2–4 personas that are most relevant to the task. Choose based on which personas would give meaningfully different and useful perspectives. For example:
   - An API design task → `architect`, `security-expert`, `senior-engineer`
   - A product feature → `product-manager`, `product-researcher`, `senior-engineer`
   - A legal contract → `legal-reviewer` only (don't dilute with irrelevant perspectives)

4. Read the full file for each selected persona. For each persona, also read any files listed in its `**References:**` section.

5. Launch one sub-agent per selected persona **in parallel** using the Agent tool. Use this prompt structure for each:

```
You are operating as the following expert persona. Apply this persona fully for all responses.

---
[full persona file content]
---

[If references were loaded for this persona, include them here:]
## Reference Materials

### [reference filename 1]
[reference file 1 content]

### [reference filename 2]
[reference file 2 content]

Task:
[task]

Complete the task above from the perspective of this persona. Apply the persona's priorities, communication style, and domain expertise throughout your response. Use the reference materials above where relevant. Be concise — focus on the insights unique to your role.
```

6. Once all sub-agents return, present the results in clearly labeled sections:

```
## Multi-Persona Analysis

**Task:** [task]
**Perspectives:** [list of persona names used]

---

### [Persona 1 Name]
[result]

---

### [Persona 2 Name]
[result]

---

### [Persona 3 Name]
[result]
```

7. After all results, add a brief **Synthesis** section (3–5 bullets) that surfaces the key points of agreement and disagreement across the personas.

   Note that the session persona (if one is active) was not affected — it remains unchanged.

---

## `/persona <name>`

When $ARGUMENTS is any other value, treat it as a persona name:

1. **Normalize** the input: lowercase it and replace any spaces with hyphens. Use this normalized value for all matching below.

2. **Exact match**: try `${CLAUDE_SKILL_DIR}/personas/<normalized>.md`. If it exists, jump to step 5.

3. **Partial match**: Glob all `.md` files in `${CLAUDE_SKILL_DIR}/personas/` and collect filenames (without extension). Check if any filename *contains* the normalized input as a substring.
   - If exactly one file matches: jump to step 5 using that file.
   - If multiple files match: say "Multiple personas match '<input>': [list]. Which did you mean?" and stop.

4. **No match — suggest closest**: no exact or partial match was found. Compare the normalized input against all available persona names and identify the closest one by spelling similarity. Say: "No persona named '<input>' found. Did you mean **<closest>**? Available: [full list]" — then stop.

5. Read the full persona file.
6. Confirm: "Persona activated: **<name>**. [One sentence summarizing who they are and their style.]"
7. **Immediately adopt this persona** — don't wait for the next message.
8. **For every subsequent response in this conversation**, before formulating your reply, re-apply the persona's priorities, communication style, and domain expertise as defined in the file. If you notice your response drifting toward generic Claude behavior, correct course and re-anchor to the persona.
9. **Do not pre-load references.** If the persona file contains a `**References:**` section, do not read those files on activation. Instead, consult them during the conversation when the task warrants it, as indicated by the when-to-consult criteria listed next to each reference path. Use the Read tool to load a reference file at the moment it becomes relevant.
