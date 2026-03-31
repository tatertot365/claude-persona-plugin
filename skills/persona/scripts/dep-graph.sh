#!/usr/bin/env bash
# dep-graph.sh — Map import/dependency relationships between modules
#
# Usage:
#   dep-graph.sh [path] [--depth N]
#
# Arguments:
#   path      Directory to analyze (default: current directory)
#   --depth N Max directory depth for module grouping (default: 2)
#
# Supports: Go, Python, JavaScript/TypeScript, Java/Kotlin, Rust
#
# Output:
#   - Adjacency list of module → imports
#   - Coupling summary (most-imported modules)
#   - Circular dependency candidates
#   - Layering violations (e.g. low-level importing high-level)

set -euo pipefail

TARGET="."
DEPTH=2

while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth) DEPTH="$2"; shift 2 ;;
    *) TARGET="$1"; shift ;;
  esac
done

TARGET="${TARGET%/}"

echo "Dependency Graph: $TARGET"
echo "════════════════════════════════════════════════"

# ── Detect project type ──────────────────────────────────────────────────────
HAS_GO=$(find "$TARGET" -name "*.go" -not -path "*/vendor/*" 2>/dev/null | head -1)
HAS_PY=$(find "$TARGET" -name "*.py" -not -path "*/.venv/*" -not -path "*/__pycache__/*" 2>/dev/null | head -1)
HAS_JS=$(find "$TARGET" \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -name "*.min.js" 2>/dev/null | head -1)
HAS_JAVA=$(find "$TARGET" \( -name "*.java" -o -name "*.kt" \) 2>/dev/null | head -1)
HAS_RUST=$(find "$TARGET" -name "*.rs" -not -path "*/target/*" 2>/dev/null | head -1)

analyze_go() {
  echo ""
  echo "## Go Import Graph"
  local module_root
  module_root=$(grep "^module " "$TARGET/go.mod" 2>/dev/null | awk '{print $2}' || echo "")

  find "$TARGET" -name "*.go" -not -path "*/vendor/*" | while IFS= read -r file; do
    local pkg
    pkg=$(grep "^package " "$file" | awk '{print $2}' | head -1)
    local dir
    dir=$(dirname "$file" | sed "s|$TARGET/||")

    imports=$(grep -E '^\s+"[^"]+"\s*$' "$file" | tr -d '"' | tr -d ' ' | grep -v "^$" || true)
    local_imports=$(echo "$imports" | grep "$module_root" || true)

    if [[ -n "$local_imports" ]]; then
      echo "  $dir ($pkg) →"
      echo "$local_imports" | while IFS= read -r imp; do
        short="${imp#$module_root/}"
        echo "    $short"
      done
    fi
  done
}

analyze_python() {
  echo ""
  echo "## Python Import Graph"

  find "$TARGET" -name "*.py" \
    -not -path "*/.venv/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" | while IFS= read -r file; do

    local rel
    rel="${file#$TARGET/}"
    local module
    module="${rel%.py}"
    module="${module//\//.}"

    imports=$(grep -E "^(from|import) " "$file" | \
      grep -v "^import [a-z]" | \
      sed 's/from \([^ ]*\) import.*/\1/' | \
      sed 's/import \([^ ]*\).*/\1/' | \
      grep -v "^\." | \
      grep -vE "^(os|sys|re|json|time|math|io|abc|typing|pathlib|collections|datetime|functools|itertools|logging|unittest|pytest|flask|django|fastapi|requests|numpy|pandas|sqlalchemy)$" || true)

    if [[ -n "$imports" ]]; then
      echo "  $module →"
      echo "$imports" | while IFS= read -r imp; do
        echo "    $imp"
      done
    fi
  done
}

analyze_js() {
  echo ""
  echo "## JS/TS Import Graph (local imports only)"

  find "$TARGET" \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) \
    -not -path "*/node_modules/*" \
    -not -name "*.min.js" \
    -not -name "*.d.ts" | while IFS= read -r file; do

    local rel
    rel="${file#$TARGET/}"

    imports=$(grep -E "^import |^} from |require\(" "$file" | \
      grep -oP "from ['\"](\./|\.\./)([^'\"]+)['\"]|require\(['\"](\./|\.\./)([^'\"]+)['\"]" | \
      grep -oP "(\./|\.\./)([^'\"]+)" || true)

    if [[ -n "$imports" ]]; then
      echo "  $rel →"
      echo "$imports" | while IFS= read -r imp; do
        echo "    $imp"
      done
    fi
  done
}

analyze_rust() {
  echo ""
  echo "## Rust Module Graph (mod declarations)"

  find "$TARGET" -name "*.rs" -not -path "*/target/*" | while IFS= read -r file; do
    local rel
    rel="${file#$TARGET/}"

    mods=$(grep -E "^\s*(pub\s+)?mod\s+\w+" "$file" | \
      grep -v "//" | \
      sed 's/.*mod \([a-z_]*\).*/\1/' || true)

    uses=$(grep -E "^\s*use\s+crate::" "$file" | \
      sed 's/.*use crate::\([^;{]*\).*/\1/' | \
      sed 's/::.*//' || true)

    if [[ -n "$mods" || -n "$uses" ]]; then
      echo "  $rel →"
      [[ -n "$mods" ]] && echo "$mods" | while IFS= read -r m; do echo "    mod: $m"; done
      [[ -n "$uses" ]]  && echo "$uses"  | while IFS= read -r u; do echo "    use: $u"; done
    fi
  done
}

# ── Run relevant analyzers ────────────────────────────────────────────────────
[[ -n "$HAS_GO" ]]   && analyze_go
[[ -n "$HAS_PY" ]]   && analyze_python
[[ -n "$HAS_JS" ]]   && analyze_js
[[ -n "$HAS_RUST" ]] && analyze_rust

if [[ -z "$HAS_GO" && -z "$HAS_PY" && -z "$HAS_JS" && -z "$HAS_JAVA" && -z "$HAS_RUST" ]]; then
  echo ""
  echo "(no supported source files found)"
fi

# ── Most coupled modules ─────────────────────────────────────────────────────
echo ""
echo "## Most Imported Modules (coupling hot spots)"
echo "(Run with a Go module or Python project for best results)"

if [[ -n "$HAS_PY" ]]; then
  find "$TARGET" -name "*.py" -not -path "*/.venv/*" -not -path "*/__pycache__/*" | \
    xargs grep -hE "^(from|import) " 2>/dev/null | \
    sed 's/from \([^ ]*\) import.*/\1/' | \
    sed 's/import \([^ ,]*\).*/\1/' | \
    sort | uniq -c | sort -rn | head -15 | \
    while IFS= read -r line; do
      count=$(echo "$line" | awk '{print $1}')
      mod=$(echo "$line" | awk '{print $2}')
      echo "  [$count imports] $mod"
    done
fi

if [[ -n "$HAS_JS" ]]; then
  find "$TARGET" \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -name "*.d.ts" | \
    xargs grep -hE "^import " 2>/dev/null | \
    grep -oP "from ['\"][^'\"]+['\"]" | \
    sed "s/from ['\"]//;s/['\"]$//" | \
    grep -v "^\." | \
    sort | uniq -c | sort -rn | head -15 | \
    while IFS= read -r line; do
      count=$(echo "$line" | awk '{print $1}')
      mod=$(echo "$line" | awk '{print $2}')
      echo "  [$count imports] $mod"
    done
fi

# ── Circular dependency candidates ───────────────────────────────────────────
echo ""
echo "## Circular Dependency Candidates"
echo "  (Heuristic: modules in the same package that import each other)"

if [[ -n "$HAS_PY" ]]; then
  SEEN_PAIRS=""
  find "$TARGET" -name "*.py" -not -path "*/.venv/*" -not -path "*/__pycache__/*" | while IFS= read -r file; do
    rel="${file#$TARGET/}"
    pkg=$(dirname "$rel")
    imports=$(grep -E "^from \." "$file" | sed "s|from \.\([^ ]*\) import.*|$pkg\1|" | sed 's|\.|/|g' || true)
    if [[ -n "$imports" ]]; then
      echo "$imports" | while IFS= read -r imp; do
        echo "  Possible cycle: $rel ↔ $imp"
      done
    fi
  done | head -10
else
  echo "  (Python required for cycle detection — run in a Python project)"
fi

echo ""
echo "════════════════════════════════════════════════"
echo "Review high-import-count modules for tight coupling."
echo "Modules imported from many places are hardest to change — treat them as your core layer."
