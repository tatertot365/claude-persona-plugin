#!/usr/bin/env bash
# review-diff.sh — Produce a structured inventory of a diff for code review
#
# Usage:
#   review-diff.sh [ref_or_file]
#
# Arguments:
#   ref_or_file   A git ref (branch, commit SHA, "HEAD~1"), a file path to a
#                 saved diff, or omitted to diff staged+unstaged changes.
#
# Examples:
#   review-diff.sh                   # diff of current working tree vs HEAD
#   review-diff.sh HEAD~1            # last commit
#   review-diff.sh main              # current branch vs main
#   review-diff.sh feature..main     # range between two refs
#   review-diff.sh ./changes.patch   # pre-saved diff file
#
# Output:
#   Structured summary: files changed, functions affected, new public symbols,
#   TODOs introduced, test coverage signal, and a risk flag.

set -euo pipefail

INPUT="${1:-}"
DIFF=""

# ── Obtain the diff ─────────────────────────────────────────────────────────
if [[ -z "$INPUT" ]]; then
  DIFF=$(git diff HEAD 2>/dev/null || true)
  LABEL="working tree vs HEAD"
elif [[ -f "$INPUT" ]]; then
  DIFF=$(cat "$INPUT")
  LABEL="$INPUT"
else
  # Try as a git ref or range
  if git rev-parse --git-dir > /dev/null 2>&1; then
    DIFF=$(git diff "$INPUT" 2>/dev/null || git diff "${INPUT}..." 2>/dev/null || true)
    LABEL="$INPUT"
  fi
fi

if [[ -z "$DIFF" ]]; then
  echo "No diff found for: ${INPUT:-working tree}"
  exit 0
fi

echo "Diff inventory: $LABEL"
echo "════════════════════════════════════════════════"

# ── Files changed ────────────────────────────────────────────────────────────
echo ""
echo "## Files Changed"
FILES_ADDED=()
FILES_MODIFIED=()
FILES_DELETED=()
FILES_RENAMED=()

while IFS= read -r line; do
  case "$line" in
    "new file mode"*)      ;;
    "deleted file mode"*)  ;;
    "rename from "*)       FILES_RENAMED+=("${line#rename from }") ;;
    "--- /dev/null")       ;;
    "+++ b/"*)
      f="${line#+++ b/}"
      if echo "$DIFF" | grep -q "^new file mode" 2>/dev/null; then
        FILES_ADDED+=("$f")
      else
        FILES_MODIFIED+=("$f")
      fi
      ;;
  esac
done <<< "$DIFF"

# Simpler approach: parse diff --stat style info from the diff itself
CHANGED_FILES=$(echo "$DIFF" | grep "^diff --git" | sed 's|diff --git a/.* b/||' | sort -u || true)
ADDED_FILES=$(echo "$DIFF" | grep -A1 "^diff --git" | grep -c "^new file"; true)
DELETED_FILES=$(echo "$DIFF" | grep -A1 "^diff --git" | grep -c "^deleted file"; true)
TOTAL_FILES=$(echo "$CHANGED_FILES" | grep -c .; true)

echo "$CHANGED_FILES" | while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  if echo "$DIFF" | grep -q "^new file" && echo "$DIFF" | grep -q "b/$f$"; then
    echo "  + $f  (new)"
  else
    echo "    $f"
  fi
done

echo ""
echo "  Total: $TOTAL_FILES file(s) touched  |  $ADDED_FILES new  |  $DELETED_FILES deleted"

# ── Lines added / removed ────────────────────────────────────────────────────
echo ""
echo "## Change Volume"
ADDED_LINES=$(echo "$DIFF" | grep "^+" | grep -v "^+++" | wc -l | tr -d ' ')
REMOVED_LINES=$(echo "$DIFF" | grep "^-" | grep -v "^---" | wc -l | tr -d ' ')
echo "  +$ADDED_LINES lines added  /  -$REMOVED_LINES lines removed"

# ── Function / method signatures changed ────────────────────────────────────
echo ""
echo "## Functions / Methods Touched"
FUNC_LINES=$(echo "$DIFF" | grep "^@@" | perl -ne 'if (/\+\d+,\d+ @@\s*(.+)/) { print "$1\n" }' | grep -E '\b(func |def |function |async function |class |interface |type )' | sed 's/^[[:space:]]*//' | sort -u || true)

if [[ -n "$FUNC_LINES" ]]; then
  echo "$FUNC_LINES" | while IFS= read -r fn; do
    echo "  • $fn"
  done
else
  echo "  (none detected — check diff context lines)"
fi

# ── New public symbols ───────────────────────────────────────────────────────
echo ""
echo "## New Public Symbols (exports / public API surface)"
NEW_EXPORTS=$(echo "$DIFF" | grep "^+" | grep -v "^+++" | grep -E '^\+\s*(export (const|function|class|type|interface|default)|pub fn |public (class|interface|function|void|static)|module\.exports)' | sed 's/^+//' | sed 's/^[[:space:]]*//' | sort -u || true)

if [[ -n "$NEW_EXPORTS" ]]; then
  echo "$NEW_EXPORTS" | while IFS= read -r sym; do
    echo "  • $sym"
  done
else
  echo "  (none detected)"
fi

# ── TODOs / FIXMEs introduced ────────────────────────────────────────────────
echo ""
echo "## TODOs / FIXMEs Introduced"
TODOS=$(echo "$DIFF" | grep "^+" | grep -v "^+++" | grep -iE '\b(TODO|FIXME|HACK|XXX)\b' || true)

if [[ -n "$TODOS" ]]; then
  echo "$TODOS" | while IFS= read -r t; do
    echo "  ⚠  ${t:1}"
  done
else
  echo "  (none)"
fi

# ── Test coverage signal ─────────────────────────────────────────────────────
echo ""
echo "## Test Coverage Signal"
TEST_FILES=$(echo "$CHANGED_FILES" | grep -cE '(_test\.|\.test\.|\.spec\.|_spec\.)'; true)
SOURCE_FILES=$(echo "$CHANGED_FILES" | grep -cvE '(_test\.|\.test\.|\.spec\.|_spec\.)'; true)
ASSERT_LINES=$(echo "$DIFF" | grep "^+" | grep -v "^+++" | grep -icE '\b(assert|expect|should\.|test\(|it\(|describe\()'; true)

echo "  Source files changed:  $SOURCE_FILES"
echo "  Test files changed:    $TEST_FILES"
echo "  New assertion lines:   $ASSERT_LINES"

if [[ "$SOURCE_FILES" -gt 0 && "$TEST_FILES" -eq 0 ]]; then
  echo "  ⚠  Source changed with no test file changes — verify test coverage"
fi

# ── Risk flags ───────────────────────────────────────────────────────────────
echo ""
echo "## Risk Flags"
RISK=0

MIGRATION=$(echo "$CHANGED_FILES" | grep -ciE '(migration|schema|alembic)'; true)
[[ "$MIGRATION" -gt 0 ]] && echo "  🔴 Database migration included" && RISK=1

DEPS=$(echo "$CHANGED_FILES" | grep -ciE '(package\.json|go\.mod|requirements\.txt|Gemfile|Cargo\.toml|pom\.xml)'; true)
[[ "$DEPS" -gt 0 ]] && echo "  🟡 Dependency file changed — check for version bumps" && RISK=1

AUTH=$(echo "$DIFF" | grep -ciE '\b(auth|login|session|token|permission|role|jwt|oauth)\b'; true)
[[ "$AUTH" -gt 3 ]] && echo "  🔴 Auth/session related changes detected ($AUTH lines)" && RISK=1

CONFIG=$(echo "$CHANGED_FILES" | grep -iE '\.(env|yaml|yml|json|toml|ini|conf)$' | grep -cv test; true)
[[ "$CONFIG" -gt 0 ]] && echo "  🟡 Config file(s) changed" && RISK=1

[[ "$RISK" -eq 0 ]] && echo "  (none flagged)"

echo ""
echo "════════════════════════════════════════════════"
echo "Review inventory complete. Use this as your starting checklist."
