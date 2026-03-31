# Bug Patterns by Symptom — Lookup Reference

Symptoms are observable. Root causes are what you fix. Use this table to translate what you see into what to investigate.

Root causes are ranked by probability for typical production systems. Start at rank 1 and work down.

---

## Memory

### Symptom: Growing Memory Usage (Memory Leak)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Unbounded caches or collections** — items added but never removed (e.g., a `Map` used as a registry with no eviction) | Heap dump: find the largest retained object graph; look for collections growing without bound |
| 2 | **Event listeners / callbacks not deregistered** — objects kept alive by references in an event emitter or observer registry | Heap dump: look for listener arrays holding references to otherwise-unreachable objects |
| 3 | **Long-lived request or session context** — per-request objects stored in a global or static field, never cleared | Add logging at allocation and release sites; check whether release is called on every code path including error paths |
| 4 | **Circular references in garbage-collected languages with ref-counting** (e.g., older Python, some JS engines) | Use the language's memory profiler to identify reference cycles (Python `gc.collect()` + `gc.garbage`) |
| 5 | **Native resource handles not closed** — file descriptors, DB connections, sockets accumulate | Track open file descriptor count (`lsof -p <pid>`); add explicit close calls in `finally`/`defer`/`with` blocks |

### Symptom: Crash on Allocation (OOM)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Single large allocation** — loading an entire file, result set, or blob into memory at once | Log allocation sizes at the crash site; stream or paginate instead |
| 2 | **Memory already exhausted before this allocation** — a slow leak finally hits the limit | Check resident set size trend over time in metrics; this is likely a leak (see above) hitting a ceiling |
| 3 | **JVM/runtime heap cap too low for the actual working set** | Compare `-Xmx` or equivalent to observed peak heap; bump ceiling and re-evaluate working set size |
| 4 | **Recursive function without a termination condition** — stack overflow manifests as allocation failure on some runtimes | Check stack depth at crash; add recursion depth guard |

### Symptom: Memory Corruption

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Buffer overflow / out-of-bounds write** — writing past the end of an array overwrites adjacent memory | Run under AddressSanitizer (C/C++) or Valgrind; crash will point to the write site |
| 2 | **Use-after-free** — pointer/reference used after the backing memory is released | AddressSanitizer detects this; look for manual `free()` calls or ownership ambiguity |
| 3 | **Unsafe concurrent access** — two threads writing to the same memory location without synchronization | Run under ThreadSanitizer; look for unsynchronized writes to shared state |
| 4 | **Incorrect memory aliasing** — two pointers assumed to be non-overlapping are not (violates strict aliasing rules in C) | Compile with `-fno-strict-aliasing` as a temporary diagnostic; rewrite with explicit copies |

---

## Concurrency

### Symptom: Intermittent Failures (Heisenbugs)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Race condition on shared mutable state** — outcome depends on thread scheduling order | Run under ThreadSanitizer or Helgrind; add logging with thread IDs around the suspected shared variable |
| 2 | **Timing-dependent test** — test assumes an async operation completes within a fixed sleep | Replace sleeps with explicit waits/assertions; run the test 1000 times in a loop to confirm |
| 3 | **Non-idempotent operation called multiple times** — retry logic or at-least-once delivery triggers duplicate side effects | Add request IDs and idempotency keys; log each invocation; check for duplicate processing in logs |
| 4 | **External state not properly reset between test runs** — test pollution | Run the failing test in isolation; if it passes alone, a prior test is leaving dirty state |

### Symptom: Deadlock

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Lock ordering inconsistency** — thread A acquires lock 1 then lock 2; thread B acquires lock 2 then lock 1 | Take a thread dump; look for a cycle in the "waiting for" graph |
| 2 | **Lock held across a blocking I/O or network call** — a thread holds a lock and blocks indefinitely | Review all lock acquisition sites; ensure no I/O happens while a lock is held |
| 3 | **Database deadlock** — two transactions waiting on each other's row locks | Check the DB deadlock log (e.g., `SHOW ENGINE INNODB STATUS`); identify the conflicting row locks and reorder operations |
| 4 | **Semaphore / channel not signaled on error path** — a consumer waits forever because the producer errored without sending | Audit every code path that should signal/close a channel or semaphore; ensure error branches signal as well |

### Symptom: Incorrect Results Under Load

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Unsynchronized read-modify-write** — check-then-act without atomicity (e.g., `if count < max: count += 1`) | Replace with atomic operations or mutex; confirm with load test + assertion on final count |
| 2 | **Stale cache serving incorrect data** under concurrent writes | Check cache invalidation logic; add cache hit/miss logging; verify write-through or TTL behavior under load |
| 3 | **Thread-local state leaking between requests** — a thread pool reuses threads that carry leftover context | Audit thread-local variables; ensure cleanup at the end of each request handler |

---

## Performance

### Symptom: Sudden Slowdown (Was Fast, Now Slow)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Missing or dropped database index** — a query that was using an index is now doing a full scan | Run `EXPLAIN`/`EXPLAIN ANALYZE` on the slow query; compare query plan before and after the slowdown |
| 2 | **Recent code change introduced an N+1 query** — a loop now issues one DB query per item | Enable query logging; look for repeated identical queries with different parameters |
| 3 | **Data volume crossed a threshold** — an algorithm that was O(n²) or a table scan that was cheap on small data | Check data growth rate; profile the slow operation; look for linear or quadratic scaling |
| 4 | **Lock contention increased** — a new feature holds a hot lock longer | Check DB lock wait times and application-level lock contention metrics |
| 5 | **Garbage collection pressure** — heap is 80%+ full, GC running frequently | Check GC logs or JVM metrics; review recent allocations for objects with unexpectedly long lifetimes |

### Symptom: Latency Spike (P99 High, Median Fine)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **GC pause (stop-the-world)** — long GC pauses inflate tail latency | Correlate GC log timestamps with latency spike timestamps; tune heap size or GC algorithm |
| 2 | **Slow downstream dependency at tail** — one backend call occasionally takes 10x longer | Trace requests end-to-end; isolate which downstream call's P99 matches the overall P99 |
| 3 | **Lock convoy** — many threads queuing behind one long-held lock | Profile lock wait times; check for lock holders that do slow work before releasing |
| 4 | **Connection pool exhaustion** — requests wait for an available DB/HTTP connection | Monitor connection pool `waitingCount` or `pendingAcquire` metrics; increase pool size or reduce hold time |

### Symptom: Throughput Drop (Lower RPS than Expected)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Saturated resource** — CPU, disk I/O, or network bandwidth at 100% | Check system metrics; identify the saturated resource; profile what is consuming it |
| 2 | **Thread pool too small** — workers are all busy; new requests queue | Check queue depth and thread pool utilization; tune pool size or optimize handler speed |
| 3 | **Serialization bottleneck** — a single-threaded component (e.g., a global mutex, a single Kafka partition) is the chokepoint | Profile concurrency; look for a single thread or component processing all traffic |
| 4 | **Rate limiting or throttling in a dependency** — downstream is rejecting calls silently | Check for HTTP 429 responses or throttle errors in logs; implement exponential backoff and client-side rate limiting |

---

## Network / Distributed

### Symptom: Timeouts

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Downstream service slow or overloaded** — not network packet loss, just slow response | Compare the downstream service's own latency metrics to the timeout window; is it taking longer than the caller's timeout? |
| 2 | **Timeout set too aggressively short** — misconfigured client timeout is lower than the realistic P99 response time | Log actual response times from the downstream; compare to the configured timeout |
| 3 | **Network partition or packet loss** — packets are dropped between services | Use `ping`/`traceroute`/`mtr` to check connectivity; check network interface error counters |
| 4 | **Connection pool or thread pool exhaustion at receiver** — connection accepted but never processed | Check server-side queue depth and thread pool metrics; look for `ESTABLISHED` connections with no data flowing (`netstat -an`) |
| 5 | **Cascading timeout** — an upstream caller's timeout is shorter than the sum of downstream timeouts, causing a timeout storm | Audit timeout budgets across the call chain; implement context propagation so nested calls honor the remaining deadline |

### Symptom: Split-Brain

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Network partition without a quorum check** — two isolated node groups both believe they are the primary | Inspect leader election logic; verify quorum requirement is `floor(N/2) + 1`; check partition detection in logs |
| 2 | **Fencing token not enforced** — an old leader continues to write after a new one is elected | Confirm storage layer enforces fencing tokens (monotonically increasing epoch); reject writes from stale leaders |
| 3 | **Heartbeat timeout too short** — a slow-but-alive node is declared dead, triggering unnecessary re-election | Tune heartbeat timeout to be 3–5× the P99 heartbeat round-trip; review recent elections in the log |

### Symptom: Message Duplication

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **At-least-once delivery + non-idempotent consumer** — the queue redelivers on timeout; the consumer processes twice | Check the consumer for idempotency; add a deduplication key or a processed-message store |
| 2 | **Retry on failure without checking if the first attempt succeeded** — producer retries a write that actually committed | Add a unique request ID to writes; check on retry whether the ID was already committed before re-submitting |
| 3 | **Multiple consumer instances reading the same partition** — misconfigured consumer group | Verify consumer group ID is consistent across all instances; check partition assignment |

---

## Application Logic

### Symptom: Wrong Output

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Incorrect formula or business logic** — the code implements something close to but not exactly the spec | Trace the calculation step-by-step with known inputs and expected outputs; compare at each step |
| 2 | **Integer overflow or floating-point precision** — arithmetic wraps or loses precision silently | Log intermediate values; check for values near `INT_MAX` or precision-sensitive float comparisons; use `decimal` types for currency |
| 3 | **Wrong variable used** — a copy-paste error or shadowed variable name | Add assertions at key checkpoints; review shadowed variables in nested scopes |
| 4 | **Stale data from cache** — correct logic, but operating on outdated inputs | Bypass cache and check if result is now correct; review cache invalidation |

### Symptom: Silent Failure (No Error, Wrong Outcome)

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Swallowed exception** — `catch (e) {}` or `catch (e) { log.warn(...) }` that discards the error | Search for empty catch blocks; add re-throws or propagate errors; check warn-level logs for hidden errors |
| 2 | **Unchecked return value** — function returns an error code or `null` that the caller ignores | Check return values of all I/O operations; use a linter rule to enforce error checks |
| 3 | **Async operation not awaited** — a `Promise` or goroutine fires but the result is never observed | Look for floating promises (`void fn()` calling async operations); use `eslint/no-floating-promises` or equivalent |
| 4 | **Condition never true / branch never taken** — the code path that would produce output has a logic error that skips it | Add logging at branch entry points; verify the condition is actually being met with the test input |

### Symptom: Off-by-One Error

| Rank | Likely Root Cause | Diagnostic Step |
|---|---|---|
| 1 | **Incorrect loop boundary** — `< length` vs `<= length`, or starting at 0 vs 1 | Test with a single-element array and a two-element array; trace the loop bounds manually |
| 2 | **Inclusive vs. exclusive range confusion** — ambiguity about whether an endpoint is included | Define and document range conventions (half-open `[start, end)` is standard); check all slice/substring calls against the convention |
| 3 | **Fencepost error in pagination** — calculating page offset or limit incorrectly at boundaries | Test the first page, last page, and a page at an exact multiple of page size |
| 4 | **Date/time boundary** — "today's records" query uses `<` instead of `<=` on midnight, or mixes UTC with local time | Log the exact query parameters; verify timestamp boundaries with a known dataset straddling midnight |
