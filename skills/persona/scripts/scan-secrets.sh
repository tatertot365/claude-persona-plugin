#!/usr/bin/env bash
# scan-secrets.sh — Scan files for hardcoded secrets, API keys, and tokens
#
# Usage:
#   scan-secrets.sh [path]
#
# Arguments:
#   path  File or directory to scan (default: current directory)
#
# Output:
#   Prints matching lines with file, line number, pattern matched, and severity.

set -euo pipefail

TARGET="${1:-.}"

# ANSI colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

CRITICAL_PATTERNS=(
  "AKIA[0-9A-Z]{16}:AWS Access Key ID"
  "(?i)(password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{4,}['\"][^#]:Hardcoded password"
  "(?i)(secret|api_?key|api_?secret|auth_?token|access_?token)\s*[:=]\s*['\"][^'\"]{8,}['\"][^#]:Hardcoded secret/token"
  "-----BEGIN (RSA|EC|DSA|OPENSSH) PRIVATE KEY-----:Private key"
  "(?i)ghp_[0-9a-zA-Z]{36}:GitHub Personal Access Token"
  "(?i)sk-[a-zA-Z0-9]{32,}:OpenAI/Stripe-style secret key"
  "(?i)xox[baprs]-[0-9a-zA-Z\-]{10,}:Slack token"
)

HIGH_PATTERNS=(
  "(?i)(db_?pass|database_?password|db_?password)\s*[:=]\s*['\"][^'\"]{4,}['\"][^#]:Database password"
  "(?i)(private_?key|priv_?key)\s*[:=]\s*['\"][^'\"]{8,}['\"][^#]:Private key value"
  "(?i)(jwt_?secret|token_?secret|signing_?key)\s*[:=]\s*['\"][^'\"]{8,}['\"][^#]:JWT/signing secret"
  "(?i)bearer\s+[a-zA-Z0-9\-_\.]{20,}:Bearer token in code"
)

MEDIUM_PATTERNS=(
  "(?i)(api_?url|endpoint)\s*[:=]\s*['\"]https?://[^'\"]+['\"][^#]:Hardcoded endpoint URL"
  "(?i)(username|user_?name)\s*[:=]\s*['\"][^'\"]{3,}['\"][^#]:Hardcoded username"
  "(?i)TODO.*(secret|password|token|key|auth):TODO referencing credential"
)

PRUNE_DIRS=".git node_modules vendor .venv dist build"
SKIP_EXTS=".min.js .lock .sum"

found=0

# perl_grep_r: recursive Perl-regex search, prints file:line:match
perl_grep_r() {
  local pattern="$1"
  local root="$2"
  find "$root" -type f | while IFS= read -r f; do
    # skip excluded dirs
    local skip=0
    for d in $PRUNE_DIRS; do
      case "$f" in *"/$d/"*|*"/$d") skip=1; break ;; esac
    done
    [[ "$skip" -eq 1 ]] && continue
    # skip excluded extensions
    for e in $SKIP_EXTS; do
      case "$f" in *"$e") skip=1; break ;; esac
    done
    [[ "$skip" -eq 1 ]] && continue
    perl -ne "if (/${pattern}/) { print \"$f:\$.: \$_\" }" "$f" 2>/dev/null
  done
}

scan_patterns() {
  local severity="$1"
  local color="$2"
  shift 2
  local patterns=("$@")

  for entry in "${patterns[@]}"; do
    pattern="${entry%%:*}"
    label="${entry##*:}"

    while IFS= read -r line; do
      if [[ -n "$line" ]]; then
        echo -e "${color}[${severity}]${RESET} ${label}"
        echo "  $line"
        echo ""
        found=1
      fi
    done < <(perl_grep_r "$pattern" "$TARGET" 2>/dev/null || true)
  done
}

echo "Scanning: $TARGET"
echo "────────────────────────────────────────────────"
echo ""

scan_patterns "CRITICAL" "$RED" "${CRITICAL_PATTERNS[@]}"
scan_patterns "HIGH    " "$YELLOW" "${HIGH_PATTERNS[@]}"
scan_patterns "MEDIUM  " "$CYAN" "${MEDIUM_PATTERNS[@]}"

echo "────────────────────────────────────────────────"
if [[ $found -eq 0 ]]; then
  echo "No secret patterns matched."
else
  echo -e "${YELLOW}Review matches above — false positives are possible.${RESET}"
  echo "Check: are any of these real credentials committed to source?"
fi
