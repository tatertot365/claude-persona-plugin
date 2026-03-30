# Persona Skill for Claude Code

Switch Claude into expert modes mid-conversation. One command activates a specialist persona — security expert, debugger, architect, and more — shaping Claude's priorities, communication style, and domain focus for the rest of the session.

---

## What it does

The `/persona` skill lets you:

- **Activate** a built-in or custom expert persona
- **List** all available personas
- **Create** new personas with a guided template
- **Edit** existing personas
- **Delete** personas you no longer need
- **Deactivate** the current persona and return to default Claude behavior

Personas are **session-only** — they apply for the current conversation and reset when the session ends.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed and authenticated
- Claude Code skills support (available in Claude Code CLI)

---

## Installation

Clone this repo into your Claude Code skills directory:

```bash
git clone https://github.com/tatertot365/claude-skill-personas ~/.claude/skills/persona
```

That's it. Claude Code automatically discovers skills in `~/.claude/skills/` via each skill's `SKILL.md` file.

---

## Usage

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

Use /persona <name> to activate · /persona off to deactivate · /persona create to add a new one
```

---

### Activate a persona

```
/persona security-expert
```

Fuzzy matching is supported — partial names work:

```
/persona security      → activates security-expert
/persona debug         → activates debugger
```

Once activated, Claude immediately adopts that persona's priorities, expertise, and communication style for every subsequent response in the session.

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
Name: <lowercase-hyphenated, e.g. api-architect>
Role: <one sentence describing the expert role>
Tone: <communication style, e.g. direct, educational, rigorous, warm>
Priorities: <2–3 things this expert always optimizes for>
Expertise: <key domains, tools, or methodologies>
Pitfalls: <common mistakes or anti-patterns this expert watches for>
```

Claude generates a `.md` file from your input and saves it to `~/.claude/skills/persona/personas/`. It then asks if you want to activate the new persona immediately.

---

### Edit a persona

```
/persona edit security-expert
```

Claude displays the current file contents and asks what you'd like to change. After you describe the changes, it rewrites the file and confirms what was updated.

---

### Delete a persona

```
/persona delete security-expert
```

Claude asks for confirmation before deleting. This action cannot be undone.

---

### Get help

```
/persona help
```

Prints the full command reference.

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

Personas are plain Markdown files in `~/.claude/skills/persona/personas/`. You can create one manually or use `/persona create`.

Each persona file follows this structure:

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

---

## How it works

The skill is defined in `SKILL.md` at the root of this directory. When you run `/persona <arguments>`, Claude Code loads `SKILL.md` and executes its instructions using the `Read`, `Write`, `Glob`, and `Bash` tools.

Persona files are read at activation time — Claude ingests the full file and applies it as behavioral context for the rest of the session. No model fine-tuning or external APIs are involved.

---

## File structure

```
~/.claude/skills/persona/
├── SKILL.md              # Skill definition (entry point)
└── personas/
    ├── architect.md
    ├── code-reviewer.md
    ├── data-scientist.md
    ├── debugger.md
    ├── graphic-designer.md
    ├── legal-reviewer.md
    ├── product-manager.md
    ├── product-researcher.md
    ├── security-expert.md
    ├── senior-engineer.md
    └── tech-writer.md
```
