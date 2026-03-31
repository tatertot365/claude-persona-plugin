#!/usr/bin/env bash
# git-diff-working-broken.sh — Structured diff between a working and broken git ref
#
# Usage:
#   git-diff-working-broken.sh <working-ref> <broken-ref>
#
# Arguments:
#   working-ref   The last known good commit/tag/branch (e.g. v1.2.0, main~5)
#   broken-ref    The broken commit/tag/branch (e.g. HEAD, v1.3.0, feature-branch)
#
# Examples:
#   git-diff-working-broken.sh v1.2.0 v1.3.0
#   git-diff-working-broken.sh main~10 HEAD
#   git-diff-working-broken.sh last-deploy HEAD
#
# Output:
#   Files changed grouped by type, dependency changes, config changes,
#   commits between refs, and a risk summary for focused debugging.

set -euo pipefail

WORKING="${1:-}"
BROKEN="${2:-}"

if [[ -z "$WORKING" || -z "$BROKEN" ]]; then
  echo "Usage: git-diff-working-broken.sh <working-ref> <broken-ref>"
  echo ""
  echo "Examples:"
  echo "  git-diff-working-broken.sh v1.2.0 HEAD"
  echo "  git-diff-working-broken.sh main~5 main"
  exit 1
fi

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Not inside a git repository."
  exit 1
fi

# Resolve refs
WORKING_SHA=$(git rev-parse --short "$WORKING" 2>/dev/null || echo "?")
BROKEN_SHA=$(git rev-parse --short "$BROKEN" 2>/dev/null || echo "?")

echo "Differential Debugging: $WORKING ($WORKING_SHA) → $BROKEN ($BROKEN_SHA)"
echo "════════════════════════════════════════════════"

# ── Commits between refs ─────────────────────────────────────────────────────
echo ""
echo "## Commits Introduced ($WORKING → $BROKEN)"
COMMITS=$(git log --oneline "${WORKING}..${BROKEN}" 2>/dev/null || true)
COMMIT_COUNT=$(echo "$COMMITS" | grep -c . || echo 0)

if [[ -n "$COMMITS" ]]; then
  echo "$COMMITS" | while IFS= read -r line; do
    echo "  $line"
  done
  echo ""
  echo "  Total: $COMMIT_COUNT commit(s)"
else
  echo "  (no commits — refs may be identical or in wrong order)"
fi

# ── Files changed grouped by category ────────────────────────────────────────
echo ""
echo "## Files Changed (grouped by type)"

ALL_CHANGED=$(git diff --name-status "${WORKING}..${BROKEN}" 2>/dev/null || true)

SOURCE_FILES=$(echo "$ALL_CHANGED" | grep -vE '\.(json|yaml|yml|toml|ini|env|lock|sum|mod|txt|md|rst)$' | grep -vE '^D' | awk '{print $2}' | grep -E '\.(go|py|js|ts|jsx|tsx|java|kt|rs|rb|cpp|c|cs|php)$' || true)
CONFIG_FILES=$(echo "$ALL_CHANGED" | awk '{print $2}' | grep -E '\.(yaml|yml|toml|ini|env|json)$' | grep -viE '(test|spec|package\.json|tsconfig)' || true)
DEP_FILES=$(echo "$ALL_CHANGED" | awk '{print $2}' | grep -E '(package\.json|go\.mod|go\.sum|requirements\.txt|Gemfile|Gemfile\.lock|Cargo\.toml|Cargo\.lock|pom\.xml|build\.gradle)$' || true)
MIGRATION_FILES=$(echo "$ALL_CHANGED" | awk '{print $2}' | grep -iE '(migration|schema|alembic)' || true)
TEST_FILES=$(echo "$ALL_CHANGED" | awk '{print $2}' | grep -E '(_test\.|\.test\.|\.spec\.|_spec\.)' || true)
INFRA_FILES=$(echo "$ALL_CHANGED" | awk '{print $2}' | grep -iE '(Dockerfile|docker-compose|kubernetes|k8s|terraform|\.tf$|helm|nginx|apache)' || true)
DELETED_FILES=$(echo "$ALL_CHANGED" | grep '^D' | awk '{print $2}' || true)

print_group() {
  local label="$1"
  local files="$2"
  if [[ -n "$files" ]]; then
    echo "  [$label]"
    echo "$files" | while IFS= read -r f; do
      [[ -n "$f" ]] && echo "    $f"
    done
  fi
}

print_group "Source"     "$SOURCE_FILES"
print_group "Config"     "$CONFIG_FILES"
print_group "Deps"       "$DEP_FILES"
print_group "Migrations" "$MIGRATION_FILES"
print_group "Tests"      "$TEST_FILES"
print_group "Infra"      "$INFRA_FILES"
print_group "Deleted"    "$DELETED_FILES"

TOTAL=$(echo "$ALL_CHANGED" | grep -c . || echo 0)
echo ""
echo "  Total files changed: $TOTAL"

# ── Dependency changes ───────────────────────────────────────────────────────
if [[ -n "$DEP_FILES" ]]; then
  echo ""
  echo "## Dependency Changes"
  echo "$DEP_FILES" | while IFS= read -r depfile; do
    [[ -z "$depfile" ]] && continue
    echo "  $depfile:"
    DEP_DIFF=$(git diff "${WORKING}..${BROKEN}" -- "$depfile" 2>/dev/null | grep "^[+-]" | grep -v "^[+-][+-][+-]" | head -30 || true)
    if [[ -n "$DEP_DIFF" ]]; then
      echo "$DEP_DIFF" | while IFS= read -r line; do
        echo "    $line"
      done
    else
      echo "    (no diff available)"
    fi
  done
fi

# ── Config changes ───────────────────────────────────────────────────────────
if [[ -n "$CONFIG_FILES" ]]; then
  echo ""
  echo "## Config Changes"
  echo "$CONFIG_FILES" | while IFS= read -r cf; do
    [[ -z "$cf" ]] && continue
    echo "  $cf:"
    CFG_DIFF=$(git diff "${WORKING}..${BROKEN}" -- "$cf" 2>/dev/null | grep "^[+-]" | grep -v "^[+-][+-][+-]" | head -20 || true)
    if [[ -n "$CFG_DIFF" ]]; then
      echo "$CFG_DIFF" | while IFS= read -r line; do
        echo "    $line"
      done
    else
      echo "    (no diff available)"
    fi
  done
fi

# ── Risk summary ─────────────────────────────────────────────────────────────
echo ""
echo "## Risk Summary"
RISK_ITEMS=()

[[ -n "$MIGRATION_FILES" ]] && RISK_ITEMS+=("🔴 Database migrations — check for schema incompatibility")
[[ -n "$DEP_FILES" ]]       && RISK_ITEMS+=("🟡 Dependency changes — check for breaking version bumps")
[[ -n "$INFRA_FILES" ]]     && RISK_ITEMS+=("🟡 Infrastructure/config changes — check for env differences")
[[ -n "$DELETED_FILES" ]]   && RISK_ITEMS+=("🟡 Files deleted — check for missing imports or dead references")

AUTH_CHANGES=$(git diff --unified=0 "${WORKING}..${BROKEN}" 2>/dev/null | grep "^+" | grep -ciE '\b(auth|login|session|token|permission|role|jwt|oauth)\b' || true)
[[ "$AUTH_CHANGES" -gt 2 ]] && RISK_ITEMS+=("🔴 Auth/session logic changed ($AUTH_CHANGES lines) — high regression risk")

if [[ ${#RISK_ITEMS[@]} -eq 0 ]]; then
  echo "  (no high-risk change categories detected)"
else
  for item in "${RISK_ITEMS[@]}"; do
    echo "  $item"
  done
fi

# ── Hypothesis prompt ────────────────────────────────────────────────────────
echo ""
echo "## Debugging Starting Points"
echo "  1. Start with the highest-risk category above"
echo "  2. If deps changed: did a transitive dependency introduce a breaking change?"
echo "  3. If config changed: is there an env variable or flag now required that's missing?"
echo "  4. If source changed: which commit introduced the regression? Use git bisect."
echo "     git bisect start && git bisect bad $BROKEN && git bisect good $WORKING"
echo ""
echo "════════════════════════════════════════════════"
