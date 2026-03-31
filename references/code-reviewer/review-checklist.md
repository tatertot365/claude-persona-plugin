# Code Review Checklist

Work through this checklist during a full review. Items are tiered by severity. Block the PR on any **Must Fix** item. Raise **Should Fix** items as clear requests. Use the **Nit** prefix when leaving stylistic feedback.

---

## Tier 1: Must Fix

These are blocking issues. The PR should not merge until each one is resolved.

| # | Check | What to look for |
|---|-------|-----------------|
| 1 | **Correctness: off-by-one / boundary** | Array indexing, loop bounds, inclusive vs. exclusive ranges — especially on edge-case inputs (empty, single element, max value). |
| 2 | **Null / nil dereference** | Any pointer, reference, or optional that is used without a guard, particularly values returned from external calls, maps, or type assertions. |
| 3 | **Security: injection** | User-controlled input concatenated into SQL, shell commands, HTML, or eval — look for string interpolation where a parameterized API should be used. |
| 4 | **Security: authentication/authorization gap** | New routes or operations that lack an auth check; privilege escalation paths; checks that can be bypassed by supplying crafted input. |
| 5 | **Secret or credential exposure** | Hardcoded keys, tokens, or passwords in source; credentials logged or returned in API responses; missing redaction in error messages. |
| 6 | **Data loss or corruption** | Destructive operations (delete, overwrite, truncate) without guards; missing transactions where atomicity is required; race conditions on shared mutable state. |
| 7 | **Broken public contract** | Renamed/removed public methods, changed signatures, or altered semantics that break callers without a migration path or version bump. |
| 8 | **Error swallowing** | Caught exceptions/errors that are silently discarded with no logging, no fallback, and no propagation — leaves failures invisible in production. |
| 9 | **Resource leak** | File handles, network connections, database cursors, or lock acquisitions that are not released on both the happy path and all error paths. |
| 10 | **Integer overflow / underflow** | Arithmetic on values that can reach type limits; unsigned subtraction that wraps; multiplication before bounds check. |
| 11 | **Concurrency hazard** | Shared mutable state accessed from multiple goroutines/threads without synchronization; incorrect use of atomic operations; TOCTOU (time-of-check/time-of-use) bugs. |
| 12 | **Cryptography misuse** | Homegrown crypto; use of broken algorithms (MD5, SHA-1 for security, DES, ECB mode); hardcoded IVs or salts; insecure random for security-sensitive purposes. |

---

## Tier 2: Should Fix

These are strong requests, not blocks. Leave clear comments explaining the impact. If the author disagrees, escalate the conversation rather than silently dropping the feedback.

| # | Check | What to look for |
|---|-------|-----------------|
| 1 | **Missing or inadequate error handling** | Errors acknowledged but not acted on; generic error messages that hide root cause; no distinction between retriable and fatal errors. |
| 2 | **Test coverage gap** | Happy path covered but edge cases, error paths, or boundary conditions have no tests; logic changes with zero new tests. |
| 3 | **Misleading naming** | Functions, variables, or types whose names contradict their behavior; boolean flags that are named with double negatives (`notDisabled`). |
| 4 | **Overly broad function / method** | Single function doing multiple distinct things; violates single-responsibility; hard to test in isolation. |
| 5 | **Duplicated logic** | Substantial copy-paste between two or more callsites that should share an abstraction. |
| 6 | **Magic values without context** | Unnamed numeric or string literals embedded in logic where a named constant, enum, or config value would make intent clear. |
| 7 | **Missing input validation** | Public-facing functions or API handlers that accept untrusted input without validating type, range, length, or format before use. |
| 8 | **Inconsistent state after partial failure** | Multi-step operations where a mid-sequence failure leaves the system in a state that is neither fully applied nor cleanly rolled back. |
| 9 | **Performance cliff** | N+1 query patterns; unbounded in-memory accumulation; expensive operation inside a loop that could be hoisted or batched. |
| 10 | **Inadequate logging / observability** | Operations that have no log on failure; log lines missing correlation IDs or contextual fields needed to diagnose production issues. |
| 11 | **Dependency hygiene** | New dependency added for functionality that the existing stdlib or an already-present library already provides; unpinned or wildcard version. |

---

## Tier 3: Nit

Leave these with the `nit:` prefix so the author knows they are not blocking. These are personal or team preferences, not correctness issues. Batch nits into a single comment where possible to avoid noise.

| # | Check | What to look for |
|---|-------|-----------------|
| 1 | **Formatting inconsistency** | Indentation, brace style, or spacing that differs from the surrounding file without a linter enforcement reason. |
| 2 | **Verbose or redundant comment** | Comments that restate what the code obviously does (`// increment i by 1`); outdated comments that no longer match the code. |
| 3 | **Overly long line** | Lines that exceed the project's agreed limit, making side-by-side diffs harder to read. |
| 4 | **Unnecessary abbreviation** | Single-letter or cryptic variable names where a short readable name would cost nothing (`idx` vs `i` in a non-trivial loop). |
| 5 | **Dead code / unused import** | Variables declared but never read; imports that are no longer referenced; commented-out code blocks left behind. |
| 6 | **Prefer standard idiom** | A construct that works but is less idiomatic than the language/framework standard (e.g., manual loop where a map/filter would be cleaner). |
| 7 | **TODO left without a ticket** | `// TODO` comments with no linked issue number — they tend to never get resolved. |
| 8 | **Inconsistent terminology** | The same concept referred to by two different names within the same file or module (`user` vs `account`, `id` vs `identifier`). |
