#!/usr/bin/env bash
# extract-stack-trace.sh — Parse logs/output to extract, deduplicate, and rank stack traces
#
# Usage:
#   extract-stack-trace.sh <file>
#   cat app.log | extract-stack-trace.sh -
#
# Arguments:
#   file   Log file to parse, or '-' to read from stdin
#
# Output:
#   Ranked list of unique error types with frequency count and one representative
#   stack trace per type. Turns raw noisy logs into a prioritized hypothesis list.

set -euo pipefail

INPUT="${1:-}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: extract-stack-trace.sh <file|-> "
  echo "  Pass a log file path or '-' to read from stdin."
  exit 1
fi

if [[ "$INPUT" == "-" ]]; then
  CONTENT=$(cat)
else
  if [[ ! -f "$INPUT" ]]; then
    echo "File not found: $INPUT"
    exit 1
  fi
  CONTENT=$(cat "$INPUT")
fi

if [[ -z "$CONTENT" ]]; then
  echo "Input is empty."
  exit 0
fi

echo "Stack Trace Analysis"
echo "════════════════════════════════════════════════"

# ── Detect language/runtime style ───────────────────────────────────────────
HAS_PYTHON=$(echo "$CONTENT" | grep -c "Traceback (most recent call last)" || true)
HAS_JS=$(echo "$CONTENT" | grep -cE '^\s+at [[:alnum:]]' || true)
HAS_GO=$(echo "$CONTENT" | grep -cE "goroutine [0-9]" || true)
HAS_JAVA=$(echo "$CONTENT" | grep -cE '^\s+at [a-z][A-Za-z0-9._]+\(' || true)
HAS_RUST=$(echo "$CONTENT" | grep -c "stack backtrace:" || true)

echo ""
echo "## Runtime Detection"
[[ "$HAS_PYTHON" -gt 0 ]] && echo "  Python tracebacks: $HAS_PYTHON"
[[ "$HAS_JS" -gt 0 ]]     && echo "  JS/Node frames:    $HAS_JS"
[[ "$HAS_GO" -gt 0 ]]     && echo "  Go goroutines:     $HAS_GO"
[[ "$HAS_JAVA" -gt 0 ]]   && echo "  Java frames:       $HAS_JAVA"
[[ "$HAS_RUST" -gt 0 ]]   && echo "  Rust backtraces:   $HAS_RUST"

# ── Extract and count error/exception type lines ─────────────────────────────
echo ""
echo "## Error Types (by frequency)"

ERROR_TYPES=$(echo "$CONTENT" | \
  perl -ne 'while (/(?i)(Exception|Error|Panic|panic|FATAL|fatal|SIGSEGV|SIGABRT)[:]\s*([\w\s:.+-]+)/g) { print "$1: $2\n" }' | \
  sed 's/[[:space:]]\{2,\}/ /g' | \
  sed 's/[[:space:]]*$//' | \
  sort | uniq -c | sort -rn | \
  head -20 || true)

if [[ -n "$ERROR_TYPES" ]]; then
  echo "$ERROR_TYPES" | while IFS= read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    msg=$(echo "$line" | cut -d' ' -f2-)
    echo "  [${count}x] $msg"
  done
else
  echo "  (no standard error type lines detected)"
fi

# ── Extract unique stack traces (first frame per trace) ──────────────────────
echo ""
echo "## Unique Crash Locations (first user frame)"

# Python: lines after "File " in a traceback
PYTHON_FRAMES=$(echo "$CONTENT" | grep -E '^\s+File "' | grep -v 'site-packages\|/usr/lib\|<frozen' | \
  sed 's/.*File "\(.*\)", line \([0-9]*\), in \(.*\)/  \1:\2 → \3/' | sort -u | head -15 || true)

# JS/Node: at lines excluding node internals
JS_FRAMES=$(echo "$CONTENT" | grep -E '^\s+at ' | grep -v 'node_modules\|node:internal\|<anonymous>' | \
  sed 's/[[:space:]]*at /  /' | sort -u | head -15 || true)

# Go: lines with .go: in goroutine dumps
GO_FRAMES=$(echo "$CONTENT" | grep -E '\.go:[0-9]+' | grep -v 'runtime\.' | \
  sed 's/^[[:space:]]*/  /' | sort -u | head -15 || true)

# Java: at lines excluding java.*/javax.*
JAVA_FRAMES=$(echo "$CONTENT" | grep -E '^\s+at ' | grep -v 'java\.\|javax\.\|sun\.\|com\.sun\.' | \
  sed 's/[[:space:]]*at /  /' | sort -u | head -15 || true)

[[ -n "$PYTHON_FRAMES" ]] && echo "  [Python]" && echo "$PYTHON_FRAMES"
[[ -n "$JS_FRAMES" ]]     && echo "  [JS/Node]" && echo "$JS_FRAMES"
[[ -n "$GO_FRAMES" ]]     && echo "  [Go]" && echo "$GO_FRAMES"
[[ -n "$JAVA_FRAMES" ]]   && echo "  [Java]" && echo "$JAVA_FRAMES"

if [[ -z "$PYTHON_FRAMES" && -z "$JS_FRAMES" && -z "$GO_FRAMES" && -z "$JAVA_FRAMES" ]]; then
  echo "  (no user-code frames detected)"
fi

# ── Timestamp clustering ─────────────────────────────────────────────────────
echo ""
echo "## Temporal Pattern"

TIMESTAMPS=$(echo "$CONTENT" | \
  perl -ne 'while (/(\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2})/g) { print "$1\n" }' | \
  sort | uniq -c | sort -rn | head -10 || true)

if [[ -n "$TIMESTAMPS" ]]; then
  echo "  Most active error windows:"
  echo "$TIMESTAMPS" | while IFS= read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    ts=$(echo "$line" | awk '{print $2}')
    echo "  [$count errors] $ts"
  done
else
  echo "  (no timestamps found in standard format)"
fi

# ── Repeated messages ────────────────────────────────────────────────────────
echo ""
echo "## Top Repeated Log Lines (likely root-cause candidates)"

echo "$CONTENT" | grep -iE '(error|fatal|panic|exception|fail|crash)' | \
  sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}[T ][0-9:\.Z+-]*//g' | \
  perl -pe 's/\b[0-9a-f]{8,}\b/[id]/g' | \
  sort | uniq -c | sort -rn | head -10 | \
  while IFS= read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    msg=$(echo "$line" | cut -d' ' -f2- | sed 's/^[[:space:]]*//')
    echo "  [${count}x] $msg"
  done

echo ""
echo "════════════════════════════════════════════════"
echo "Use the most frequent error types and frames as your ranked hypothesis list."
echo "Start with the highest-frequency crash location — that's your most likely root cause."
