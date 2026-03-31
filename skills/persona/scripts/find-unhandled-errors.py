#!/usr/bin/env python3
"""
find-unhandled-errors.py — Scan for swallowed or mishandled errors by language

Usage:
    python3 find-unhandled-errors.py [path]

Arguments:
    path  File or directory to scan (default: current directory)

Detects:
    Go:         ignored `err` returns, err assigned but never checked
    Python:     bare `except:`, `except Exception: pass`, silent ignores
    JS/TS:      unhandled Promise rejections, empty catch blocks, .catch(()=>{})
    Java/Kotlin: empty catch blocks, caught-and-swallowed exceptions
    Rust:       .unwrap() / .expect() in non-test code (panic risk)
"""

import re
import sys
from pathlib import Path

TARGET = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

EXCLUDE_DIRS = {".git", "node_modules", "vendor", ".venv", "dist", "build", "__pycache__"}
EXCLUDE_EXTS = {".min.js", ".lock", ".sum", ".map", ".png", ".jpg", ".svg"}

SEVERITY_COLOR = {
    "CRITICAL": "\033[0;31m",
    "HIGH":     "\033[0;33m",
    "MEDIUM":   "\033[0;36m",
}
RESET = "\033[0m"

# Each rule: (label, severity, file_glob_exts, pattern, negative_lookahead_optional)
RULES = [
    # ── Go ───────────────────────────────────────────────────────────────────
    (
        "Go: err assigned and immediately discarded (_)",
        "HIGH",
        {".go"},
        r'\b\w+,\s*_\s*:?=\s*\w+.*\berr\b|\b_\s*,\s*err\b.*:?=',
    ),
    (
        "Go: err returned but not checked (common pattern)",
        "HIGH",
        {".go"},
        r'^\s*(if\s+)?(\w+\s*,\s*)?err\s*:?=\s*.*\n(?!\s*(if|return|log|fmt\.Print|panic)\s)',
    ),
    (
        "Go: error return ignored via blank identifier",
        "MEDIUM",
        {".go"},
        r'\b_\s*=\s*\w+\(',
    ),

    # ── Python ───────────────────────────────────────────────────────────────
    (
        "Python: bare except clause (catches everything including KeyboardInterrupt)",
        "HIGH",
        {".py"},
        r'^\s*except\s*:\s*$',
    ),
    (
        "Python: except block with only pass/continue",
        "HIGH",
        {".py"},
        r'except\s+[\w\s,()]+:\s*\n\s*(pass|continue)\s*$',
    ),
    (
        "Python: exception caught and silently ignored (no log/raise/return)",
        "MEDIUM",
        {".py"},
        r'except\s+Exception\s+as\s+\w+\s*:\s*\n\s*pass',
    ),

    # ── JavaScript / TypeScript ──────────────────────────────────────────────
    (
        "JS/TS: Promise with no .catch() or await in try/catch",
        "HIGH",
        {".js", ".ts", ".jsx", ".tsx", ".mjs"},
        r'new Promise\s*\([^)]+\)(?![\s\S]{0,200}\.catch)',
    ),
    (
        "JS/TS: empty catch block",
        "HIGH",
        {".js", ".ts", ".jsx", ".tsx", ".mjs"},
        r'catch\s*\([^)]*\)\s*\{\s*\}',
    ),
    (
        "JS/TS: .catch(() => {}) — swallowed rejection",
        "HIGH",
        {".js", ".ts", ".jsx", ".tsx", ".mjs"},
        r'\.catch\s*\(\s*(?:\(\s*\w*\s*\)|_|\w+)\s*=>\s*\{\s*\}\s*\)',
    ),
    (
        "JS/TS: async function with no try/catch and no .catch chain",
        "MEDIUM",
        {".js", ".ts", ".jsx", ".tsx", ".mjs"},
        r'async\s+(?:function\s+\w+|\w+\s*=\s*async\s+function|\([^)]*\)\s*=>)',
    ),

    # ── Java / Kotlin ────────────────────────────────────────────────────────
    (
        "Java/Kotlin: empty catch block",
        "HIGH",
        {".java", ".kt"},
        r'catch\s*\([^)]+\)\s*\{\s*\}',
    ),
    (
        "Java/Kotlin: exception caught and only printed (not rethrown/logged properly)",
        "MEDIUM",
        {".java", ".kt"},
        r'catch\s*\([^)]+\)\s*\{\s*\n?\s*e\.printStackTrace\(\)',
    ),

    # ── Rust ─────────────────────────────────────────────────────────────────
    (
        "Rust: .unwrap() — panics on None/Err (avoid in production paths)",
        "MEDIUM",
        {".rs"},
        r'\.\s*unwrap\s*\(\s*\)',
    ),
    (
        "Rust: .expect() — panics with message (verify this is intentional)",
        "MEDIUM",
        {".rs"},
        r'\.\s*expect\s*\(',
    ),
]


def iter_files(root: Path):
    if root.is_file():
        yield root
        return
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in EXCLUDE_DIRS for part in path.parts):
            continue
        if any(str(path).endswith(ext) for ext in EXCLUDE_EXTS):
            continue
        yield path


def main():
    print(f"Scanning: {TARGET}")
    print("─" * 60)

    results = []

    for filepath in iter_files(TARGET):
        ext = filepath.suffix.lower()
        try:
            lines = filepath.read_text(errors="ignore").splitlines()
        except (PermissionError, IsADirectoryError):
            continue

        for label, severity, exts, pattern in RULES:
            if exts and ext not in exts:
                continue
            for lineno, line in enumerate(lines, 1):
                # Skip test files for Rust unwrap/expect
                if "unwrap" in pattern or "expect" in pattern:
                    if "_test" in str(filepath) or "test_" in str(filepath) or "/tests/" in str(filepath):
                        continue
                if re.search(pattern, line):
                    results.append((severity, label, filepath, lineno, line.strip()))

    if not results:
        print("No unhandled error patterns found.")
        return

    SEVERITY_ORDER = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2}
    results.sort(key=lambda r: (SEVERITY_ORDER.get(r[0], 9), str(r[2])))

    current_label = None
    for severity, label, filepath, lineno, line in results:
        if label != current_label:
            color = SEVERITY_COLOR.get(severity, "")
            print(f"\n{color}[{severity}] {label}{RESET}")
            current_label = label
        try:
            rel = filepath.relative_to(TARGET)
        except ValueError:
            rel = filepath
        print(f"  {rel}:{lineno}")
        print(f"    {line[:120]}")

    print("\n" + "─" * 60)
    print(f"Found {len(results)} candidate(s). Review each for context.")
    print("Not every match is a bug — check whether errors are handled at a higher level.")


if __name__ == "__main__":
    main()
