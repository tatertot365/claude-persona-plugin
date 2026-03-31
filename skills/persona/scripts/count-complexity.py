#!/usr/bin/env python3
"""
count-complexity.py — Calculate cyclomatic complexity per function

Usage:
    python3 count-complexity.py [path] [--threshold N] [--top N]

Arguments:
    path          File or directory to analyze (default: current directory)
    --threshold N Only show functions with complexity >= N (default: 5)
    --top N       Show only the top N most complex functions (default: all)

Supports: Python, JavaScript/TypeScript, Go, Java/Kotlin, Rust

Cyclomatic complexity = number of linearly independent paths through a function.
  1–4:   Simple, low risk
  5–9:   Moderate complexity — consider refactoring
  10–14: High complexity — hard to test, fragile
  15+:   Very high — strong refactor candidate

Decision points counted: if/elif/else, for, while, case/switch, catch,
logical operators (&&/||/and/or), ternary expressions, comprehensions.
"""

import re
import sys
import os
from pathlib import Path
from dataclasses import dataclass, field

TARGET = Path(".")
THRESHOLD = 5
TOP_N = None

# Parse args
args = sys.argv[1:]
i = 0
while i < len(args):
    if args[i] == "--threshold" and i + 1 < len(args):
        THRESHOLD = int(args[i + 1]); i += 2
    elif args[i] == "--top" and i + 1 < len(args):
        TOP_N = int(args[i + 1]); i += 2
    else:
        TARGET = Path(args[i]); i += 1

EXCLUDE_DIRS = {".git", "node_modules", "vendor", ".venv", "dist", "build", "__pycache__", "target"}
EXCLUDE_EXTS = {".min.js", ".d.ts", ".lock", ".sum", ".map"}

SEVERITY_COLOR = {
    "CRITICAL": "\033[0;31m",   # 15+
    "HIGH":     "\033[0;33m",   # 10-14
    "MEDIUM":   "\033[0;36m",   # 5-9
    "LOW":      "\033[0;32m",   # 1-4
}
RESET = "\033[0m"


@dataclass
class FuncResult:
    filepath: Path
    lineno: int
    name: str
    complexity: int
    language: str


def complexity_label(n: int) -> str:
    if n >= 15: return "CRITICAL"
    if n >= 10: return "HIGH"
    if n >= 5:  return "MEDIUM"
    return "LOW"


# Decision-point patterns that increment complexity
DECISION_PATTERNS = {
    "python": [
        r'\bif\b', r'\belif\b', r'\bfor\b', r'\bwhile\b',
        r'\bexcept\b', r'\band\b', r'\bor\b',
        r'\bif\b.*\belse\b',          # inline ternary
        r'\bfor\b.*\bin\b.*\bif\b',   # comprehension condition
        r'assert\s',
    ],
    "js": [
        r'\bif\b', r'\belse\s+if\b', r'\bfor\b', r'\bwhile\b', r'\bdo\b',
        r'\bcase\b', r'\bcatch\b', r'\?\s*[^:]+\s*:', r'&&', r'\|\|',
        r'\?\?',  # nullish coalescing
    ],
    "go": [
        r'\bif\b', r'\belse\s+if\b', r'\bfor\b', r'\bcase\b',
        r'\bselect\b', r'&&', r'\|\|',
    ],
    "java": [
        r'\bif\b', r'\belse\s+if\b', r'\bfor\b', r'\bwhile\b', r'\bdo\b',
        r'\bcase\b', r'\bcatch\b', r'&&', r'\|\|',
        r'\?[^:]',  # ternary
    ],
    "rust": [
        r'\bif\b', r'\belse\s+if\b', r'\bfor\b', r'\bwhile\b', r'\bloop\b',
        r'\bmatch\b', r'=>',  # match arm
        r'&&', r'\|\|', r'\bif\s+let\b', r'\bwhile\s+let\b',
    ],
}

FUNC_PATTERNS = {
    "python": re.compile(r'^\s*(?:async\s+)?def\s+(\w+)\s*\('),
    "js":     re.compile(r'(?:function\s+(\w+)|(?:const|let|var)\s+(\w+)\s*=\s*(?:async\s+)?(?:function|\([^)]*\)\s*=>)|(?:async\s+)?(\w+)\s*\([^)]*\)\s*\{)'),
    "go":     re.compile(r'^func\s+(?:\([^)]+\)\s+)?(\w+)\s*\('),
    "java":   re.compile(r'(?:public|private|protected|static|\s)+[\w<>\[\]]+\s+(\w+)\s*\([^)]*\)\s*(?:throws\s+[\w,\s]+)?\s*\{'),
    "rust":   re.compile(r'(?:pub\s+)?(?:async\s+)?fn\s+(\w+)\s*(?:<[^>]*>)?\s*\('),
}

EXT_TO_LANG = {
    ".py": "python",
    ".js": "js", ".ts": "js", ".jsx": "js", ".tsx": "js", ".mjs": "js",
    ".go": "go",
    ".java": "java", ".kt": "java",
    ".rs": "rust",
}


def analyze_file(filepath: Path) -> list[FuncResult]:
    lang = EXT_TO_LANG.get(filepath.suffix.lower())
    if not lang:
        return []

    try:
        lines = filepath.read_text(errors="ignore").splitlines()
    except (PermissionError, IsADirectoryError):
        return []

    func_pat = FUNC_PATTERNS[lang]
    dec_pats = [re.compile(p) for p in DECISION_PATTERNS[lang]]

    results = []
    in_func = False
    func_name = ""
    func_line = 0
    complexity = 1
    brace_depth = 0
    func_brace_start = 0
    indent_start = 0

    if lang == "python":
        # Python: indent-based function detection
        func_stack = []  # stack of (name, lineno, base_indent, complexity)

        for lineno, line in enumerate(lines, 1):
            stripped = line.rstrip()
            if not stripped or stripped.lstrip().startswith("#"):
                continue

            indent = len(line) - len(line.lstrip())

            # Pop functions whose indent we've dedented past
            while func_stack and indent <= func_stack[-1][2] and not re.match(r'^\s*(def|class|async\s+def)\b', line):
                name, start_line, _, comp = func_stack.pop()
                results.append(FuncResult(filepath, start_line, name, comp, lang))

            m = func_pat.match(line)
            if m:
                func_name = m.group(1)
                func_stack.append([func_name, lineno, indent, 1])

            if func_stack:
                for pat in dec_pats:
                    if pat.search(stripped):
                        func_stack[-1][3] += 1

        # Flush remaining
        for name, start_line, _, comp in func_stack:
            results.append(FuncResult(filepath, start_line, name, comp, lang))

    else:
        # Brace-based languages
        for lineno, line in enumerate(lines, 1):
            stripped = line.strip()
            if not stripped:
                continue

            m = func_pat.search(line)
            if m and not in_func:
                func_name = next((g for g in m.groups() if g), "<anonymous>")
                func_line = lineno
                in_func = True
                complexity = 1
                func_brace_start = brace_depth

            if in_func:
                brace_depth += stripped.count("{") - stripped.count("}")
                for pat in dec_pats:
                    if pat.search(stripped):
                        complexity += 1

                if in_func and brace_depth <= func_brace_start and "{" not in stripped[:stripped.find("}")+1 if "}" in stripped else 0]:
                    pass

                if in_func and brace_depth < func_brace_start + 1 and lineno > func_line:
                    results.append(FuncResult(filepath, func_line, func_name, complexity, lang))
                    in_func = False
            else:
                brace_depth += stripped.count("{") - stripped.count("}")

    return results


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
        if path.suffix.lower() in EXT_TO_LANG:
            yield path


def main():
    print(f"Cyclomatic Complexity Analysis: {TARGET}")
    print(f"Threshold: {THRESHOLD}+  |  Scale: 1-4 low · 5-9 medium · 10-14 high · 15+ critical")
    print("─" * 65)

    all_results: list[FuncResult] = []
    for f in iter_files(TARGET):
        all_results.extend(analyze_file(f))

    filtered = [r for r in all_results if r.complexity >= THRESHOLD]
    filtered.sort(key=lambda r: -r.complexity)

    if TOP_N:
        filtered = filtered[:TOP_N]

    if not filtered:
        print(f"\nNo functions found with complexity >= {THRESHOLD}.")
        total = len(all_results)
        avg = sum(r.complexity for r in all_results) / total if total else 0
        print(f"Analyzed {total} function(s). Average complexity: {avg:.1f}")
        return

    # Print results
    current_file = None
    for r in filtered:
        try:
            rel = r.filepath.relative_to(TARGET)
        except ValueError:
            rel = r.filepath
        if rel != current_file:
            print(f"\n{rel}")
            current_file = rel
        label = complexity_label(r.complexity)
        color = SEVERITY_COLOR[label]
        bar = "█" * min(r.complexity, 30)
        print(f"  {color}[{r.complexity:3d}]{RESET}  {r.name:<35}  line {r.lineno:<5}  {bar}")

    print("\n" + "─" * 65)
    total = len(all_results)
    avg = sum(r.complexity for r in all_results) / total if total else 0
    critical = sum(1 for r in all_results if r.complexity >= 15)
    high = sum(1 for r in all_results if 10 <= r.complexity < 15)

    print(f"Analyzed {total} function(s)  |  avg complexity: {avg:.1f}  |  "
          f"critical: {critical}  high: {high}  shown: {len(filtered)}")

    if filtered:
        top = filtered[0]
        try:
            rel = top.filepath.relative_to(TARGET)
        except ValueError:
            rel = top.filepath
        print(f"\nHighest: {top.name} in {rel}:{top.lineno} (complexity {top.complexity})")
        print("→ Start here. Functions above 10 are the hardest to test and most bug-prone.")


if __name__ == "__main__":
    main()
