#!/usr/bin/env python3
"""
find-injection-sinks.py — Scan for user input reaching dangerous execution sinks

Usage:
    python3 find-injection-sinks.py [path]

Arguments:
    path  File or directory to scan (default: current directory)

Output:
    Prints candidate injection points grouped by sink type and severity.
    Results are candidates — requires human review for context.
"""

import re
import sys
import os
from pathlib import Path

TARGET = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")

EXCLUDE_DIRS = {".git", "node_modules", "vendor", ".venv", "dist", "build", "__pycache__"}
EXCLUDE_EXTS = {".min.js", ".lock", ".sum", ".map", ".png", ".jpg", ".svg", ".woff", ".ttf"}

# Sink patterns: (label, severity, [regex patterns])
SINKS = [
    ("SQL Injection", "CRITICAL", [
        r'(?i)(execute|query|raw|cursor\.execute)\s*\(\s*[^)]*(%s|\+|\.format|f["\'])',
        r'(?i)(SELECT|INSERT|UPDATE|DELETE|DROP|UNION).*\+.*\b(request|params|args|body|input|user)',
        r'(?i)db\.(execute|raw)\s*\([^)]*\+',
        r'(?i)knex\.raw\s*\(',
        r'(?i)sequelize\.query\s*\([^)]*\+',
    ]),
    ("Shell Injection", "CRITICAL", [
        r'(?i)(os\.system|subprocess\.(call|run|Popen)|exec|shell_exec|popen)\s*\([^)]*\b(request|params|args|input|user|query)',
        r'(?i)(child_process\.(exec|spawn|execSync))\s*\([^)]*\+',
        r'(?i)`[^`]*(req\.|request\.|params\.|args\.|input)[^`]*`',
    ]),
    ("Code Execution (eval)", "CRITICAL", [
        r'\beval\s*\([^)]*\b(request|params|args|body|input|user|query)',
        r'(?i)(exec|compile)\s*\([^)]*\b(request|params|args|body|input)',
        r'(?i)Function\s*\(\s*[^)]*\b(request|params|input)',
    ]),
    ("Path Traversal", "HIGH", [
        r'(?i)(open|readFile|readFileSync|file_get_contents|fopen|include|require)\s*\([^)]*\b(request|params|args|body|input|user|query)',
        r'(?i)os\.path\.(join|open)\s*\([^)]*\b(request|params|args|input)',
        r'(?i)(send_file|send_from_directory|serve_file)\s*\([^)]*\b(request|params|args|input)',
    ]),
    ("XSS / Unescaped HTML Output", "HIGH", [
        r'(?i)(innerHTML|outerHTML|document\.write|insertAdjacentHTML)\s*[=+]\s*[^;]*\b(request|params|input|user|query)',
        r'(?i)(render_template_string|mark_safe|Markup\s*\()\s*[^)]*\b(request|params|input)',
        r'(?i)res\.(send|write|end)\s*\([^)]*\b(req\.|request\.|params\.|input)',
        r'\{\{\s*\w+\s*\|safe\s*\}\}',
    ]),
    ("SSRF / Unvalidated Redirect", "HIGH", [
        r'(?i)(requests\.(get|post|put)|urllib|fetch|axios|http\.get)\s*\([^)]*\b(request|params|args|body|input|url)',
        r'(?i)(redirect|header\s*\(\s*["\']location)',
        r'(?i)res\.redirect\s*\([^)]*\b(req\.|request\.|params\.|input)',
    ]),
    ("Deserialization", "HIGH", [
        r'(?i)(pickle\.loads|yaml\.load\s*\([^)]*Loader\s*=\s*None|marshal\.loads|jsonpickle\.decode)\s*\(',
        r'(?i)(unserialize|ObjectInputStream|fromJson)\s*\([^)]*\b(request|params|input)',
    ]),
]

SEVERITY_ORDER = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2}
SEVERITY_COLOR = {"CRITICAL": "\033[0;31m", "HIGH": "\033[0;33m", "MEDIUM": "\033[0;36m"}
RESET = "\033[0m"


def iter_files(root: Path):
    if root.is_file():
        yield root
        return
    for path in root.rglob("*"):
        if path.is_file():
            if any(part in EXCLUDE_DIRS for part in path.parts):
                continue
            if any(str(path).endswith(ext) for ext in EXCLUDE_EXTS):
                continue
            yield path


def scan():
    results = []  # (severity, sink_label, filepath, lineno, line)

    for filepath in iter_files(TARGET):
        try:
            text = filepath.read_text(errors="ignore")
        except (PermissionError, IsADirectoryError):
            continue

        lines = text.splitlines()
        for sink_label, severity, patterns in SINKS:
            for pattern in patterns:
                for lineno, line in enumerate(lines, 1):
                    if re.search(pattern, line):
                        results.append((severity, sink_label, filepath, lineno, line.strip()))

    return results


def main():
    print(f"Scanning: {TARGET}")
    print("─" * 60)

    results = scan()

    if not results:
        print("No injection sink candidates found.")
        return

    # Group by severity then sink
    results.sort(key=lambda r: (SEVERITY_ORDER.get(r[0], 9), r[1]))

    current_group = None
    for severity, sink_label, filepath, lineno, line in results:
        group = f"{severity}:{sink_label}"
        if group != current_group:
            color = SEVERITY_COLOR.get(severity, "")
            print(f"\n{color}[{severity}] {sink_label}{RESET}")
            current_group = group
        rel = filepath.relative_to(TARGET) if filepath.is_relative_to(TARGET) else filepath
        print(f"  {rel}:{lineno}")
        print(f"    {line[:120]}")

    print("\n" + "─" * 60)
    print(f"Found {len(results)} candidate(s). Review each — false positives likely.")
    print("Confirm whether user-controlled input reaches each sink without sanitization.")


if __name__ == "__main__":
    main()
