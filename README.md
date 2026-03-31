# Persona Plugin for Claude Code

Switch Claude into expert modes mid-conversation. One command activates a specialist persona — security expert, debugger, architect, and more — shaping Claude's priorities, communication style, and domain focus for the rest of the session.

Personas are **session-only**. They apply to the current conversation and reset when the session ends.

---

## What it does

The `/persona` command lets you:

- **Activate** a built-in or custom expert persona for your session
- **Spawn** a single persona as a sub-agent to handle a specific task
- **Multi** — run a task across several relevant personas in parallel and get a synthesized result
- **List** all available personas
- **View references** a persona uses for its expertise
- **Create** new personas with a guided template
- **Edit** existing personas
- **Delete** personas you no longer need
- **Deactivate** the current persona and return to default Claude behavior

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated

---

## Installation

Clone the repository:

```bash
git clone https://github.com/tatertot365/claude-persona-plugin
```

Then add it as a plugin in Claude Code. The exact CLI flag depends on your Claude Code version — check `claude --help` or your Claude Code settings for the plugin installation option. Point it at the cloned directory.

Claude Code discovers the `/persona` skill automatically from the plugin's `skills/persona/SKILL.md` file.

---

## Quick start

```
/persona security-expert
```

Claude confirms activation and immediately responds as a senior application security engineer. Run `/persona off` to return to default behavior.

---

## Command reference

### List available personas

```
/persona list
```

Output:

```
Available Personas
──────────────────────────────────────────────────────────────────
  architect          — Principal software architect; thinks in trade-offs, not best practices
  code-reviewer      — Meticulous reviewer who finds what matters and communicates it clearly
  debugger           — Methodical, hypothesis-driven bug diagnosis across complex systems
  security-expert    — Adversarial mindset; looks for how code can be exploited
  ...

Use /persona <name> to activate · /persona off to deactivate · /persona create to add a new one · /persona edit <name> to edit · /persona delete <name> to delete
```

---

### Activate a persona

```
/persona <name>
```

Fuzzy matching is supported — partial names work:

```
/persona security      → activates security-expert
/persona debug         → activates debugger
```

Claude confirms activation and immediately adopts the persona's priorities, expertise, and communication style for every subsequent response in the session.

---

### View a persona's references

```
/persona ref <name>
```

Lists the reference documents bundled with the persona and when to consult each one.

```
References for security-expert
──────────────────────
• owasp-top10.md — consult for web application code audits and security reviews
• owasp-api-security.md — consult when reviewing API endpoints, authentication flows, or data exposure
• cwe-quick-reference.md — consult when citing specific vulnerability classes or CWE identifiers

Use /persona ref <name> load <filename> to load a reference into the current session.
```

To load a reference file into your session context:

```
/persona ref security-expert load owasp-top10.md
```

---

### Spawn a persona as a sub-agent

```
/persona spawn <name> <task>
```

Example:

```
/persona spawn security-expert review this authentication flow for vulnerabilities
```

Launches a sub-agent that completes the task entirely through the specified persona's lens, then returns the result. Your session persona is unaffected.

Use `spawn` when you want a one-off expert opinion without switching your session context.

---

### Run a task across multiple personas in parallel

```
/persona multi <task>
```

Example:

```
/persona multi design a REST API for user authentication
```

Claude selects 2–4 personas most relevant to the task, spawns one sub-agent per persona simultaneously, and presents each result in a labeled section. A **Synthesis** section follows — key points of agreement and disagreement across all perspectives.

Example personas Claude might select for the above task: `architect`, `security-expert`, `senior-engineer`.

Your session persona is unaffected.

---

### Deactivate the current persona

```
/persona off
```

Returns Claude to default behavior. Also accepts `/persona deactivate` and `/persona reset`.

---

### Create a new persona

```
/persona create
```

Claude prompts you to fill out a template:

```
Name:       <lowercase-hyphenated, e.g. api-architect>
Role:       <one sentence describing the expert role>
Tone:       <communication style, e.g. direct, educational, rigorous, warm>
Priorities: <2–3 things this expert always optimizes for>
Expertise:  <key domains, tools, or methodologies>
Pitfalls:   <common mistakes or anti-patterns this expert watches for (optional)>
```

Claude generates a `.md` file from your input and saves it to `skills/persona/personas/`. It then asks whether to activate the new persona immediately.

---

### Edit a persona

```
/persona edit <name>
```

Claude displays the current file and asks what you'd like to change. After you describe the changes, it rewrites the file and confirms what was updated.

---

### Delete a persona

```
/persona delete <name>
```

Claude asks for confirmation before deleting. This action cannot be undone.

---

### Get help

```
/persona help
```

Prints the full command reference. Running `/persona` with no arguments shows the same output.

---

## Session persona vs. sub-agents

These two modes operate independently and can run at the same time:

| | Session (`/persona <name>`) | Sub-agent (`spawn` / `multi`) |
|---|---|---|
| **Scope** | Shapes every response in the session | Handles one specific task |
| **Persistence** | Active until `/persona off` or session ends | Completes and exits |
| **Combinable** | Yes | Yes |

Example: activate `security-expert` as your session persona, then run `/persona spawn architect design a caching layer` — both operate simultaneously without interfering.

---

## Built-in personas

| Persona | Focus |
|---|---|
| `architect` | System design, trade-offs, scalability |
| `code-reviewer` | Code quality, correctness, clear feedback |
| `data-scientist` | Statistical analysis, ML, actionable insights |
| `debugger` | Root-cause analysis across complex systems |
| `graphic-designer` | Visual design, UI/UX, design systems |
| `legal-reviewer` | Tech contracts, compliance, risk flags |
| `product-manager` | User needs, prioritization, stakeholder alignment |
| `product-researcher` | UX research, user behavior, qualitative insights |
| `security-expert` | Adversarial security, threat modeling, OWASP |
| `senior-engineer` | Pragmatic, production-hardened engineering |
| `tech-writer` | Clear documentation, developer guides, API references |

---

## Adding your own personas

Personas are plain Markdown files in `skills/persona/personas/`. Create one manually or use `/persona create`.

Each file follows this structure:

```markdown
# Name

One paragraph describing who this expert is and their default mindset.

**Priorities:**
- Priority 1
- Priority 2

**How you work:**
- Behavioral guideline 1
- Behavioral guideline 2

**Communication style:**
- Style guideline 1

**Domain expertise:**
- Domain or tool

**Pitfalls you watch for:**
- Common mistake to avoid
```

Save the file as `<name>.md` in the `personas/` directory. It appears in `/persona list` immediately.

To give a persona reference documents (files it can consult during a session), add a `**References:**` section to the persona file and place the reference files in `skills/persona/references/<name>/`. Shared references that apply to multiple personas go in `skills/persona/references/shared/`.

```markdown
**References:**
- `references/<name>/my-reference.md` — consult when ...
- `references/shared/cwe-quick-reference.md` — consult when citing CWE identifiers
```

---

## How it works

The skill is defined in `skills/persona/SKILL.md`. When you run `/persona <arguments>`, Claude Code loads that file and executes its instructions using the `Read`, `Write`, `Glob`, and `Bash` tools.

Persona files are read at activation time. Claude ingests the full file and applies it as behavioral context for the rest of the session. References are loaded on demand — not upfront — based on when the task warrants them.

No model fine-tuning or external APIs are involved.

---

## File structure

```
claude-persona-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata (hidden directory)
└── skills/
    └── persona/
        ├── SKILL.md              # Skill definition (entry point)
        ├── personas/
        │   ├── architect.md
        │   ├── code-reviewer.md
        │   ├── data-scientist.md
        │   ├── debugger.md
        │   ├── graphic-designer.md
        │   ├── legal-reviewer.md
        │   ├── product-manager.md
        │   ├── product-researcher.md
        │   ├── security-expert.md
        │   ├── senior-engineer.md
        │   └── tech-writer.md
        └── references/
            ├── shared/           # Reference files available to all personas
            │   └── cwe-quick-reference.md
            ├── architect/
            │   ├── adr-template.md
            │   └── system-design-patterns.md
            ├── security-expert/
            │   ├── owasp-top10.md
            │   └── owasp-api-security.md
            └── ...               # One directory per persona (if it has references)
```
