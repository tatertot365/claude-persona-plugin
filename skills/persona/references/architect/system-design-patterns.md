# System Design Patterns — Quick Reference

A quick reference for common patterns in distributed systems. Each entry covers intent, when to reach for it, and the key trade-off you're accepting.

---

## Caching

### Patterns at a Glance

| Pattern | One-Line Description | When to Use | Key Trade-off |
|---|---|---|---|
| **Cache-Aside (Lazy Loading)** | App checks cache first; on miss, loads from DB and populates cache | Read-heavy workloads where not every key will be needed | Risk of stale data between DB write and cache expiry; cold-start penalty on first read |
| **Write-Through** | Every DB write is also written to cache synchronously | When read-after-write consistency matters and writes are tolerable overhead | Writes are slower; cache fills with data that may never be read |
| **Write-Behind (Write-Back)** | Writes go to cache immediately; DB is updated asynchronously | High write throughput systems where brief inconsistency is acceptable | Data loss risk if cache node fails before DB flush |

### Eviction Strategies

| Strategy | Description | Best For |
|---|---|---|
| **LRU** (Least Recently Used) | Evicts the item accessed least recently | General-purpose; good default |
| **LFU** (Least Frequently Used) | Evicts items with lowest access count | Long-lived caches with skewed access patterns |
| **TTL** (Time-to-Live) | Evicts after a fixed expiry window | Caches where staleness is the primary concern (e.g., session tokens, rate limit counters) |
| **FIFO** | Evicts in insertion order | Simple queues; rarely optimal for caches |

---

## Async Processing

| Pattern | One-Line Description | When to Use | Key Trade-off |
|---|---|---|---|
| **Message Queue** (e.g., SQS, RabbitMQ) | Producer sends work items; consumers process at their own pace | Decoupling services; absorbing bursty traffic; tasks where at-least-once delivery is acceptable | At-least-once delivery requires idempotent consumers; ordering is not guaranteed without FIFO queues |
| **Event Streaming** (e.g., Kafka, Kinesis) | Events are written to an ordered, durable log; consumers track their own offset | Audit logs, event sourcing, fan-out to multiple consumers, replay capability | Operationally heavier than a queue; consumers must manage offsets |
| **Async vs. Sync Decision** | — | Use **async** when: caller doesn't need immediate result, work is slow or variable, or producer/consumer scale independently. Use **sync** when: result must be returned to the caller in real time, simplicity outweighs scalability, or strict ordering is needed across a single flow | Async adds latency visibility complexity; sync couples availability of caller and callee |

---

## Sharding

| Pattern | One-Line Description | When to Use | Key Trade-off |
|---|---|---|---|
| **Range-Based Sharding** | Rows are partitioned by a contiguous key range (e.g., A–M on shard 1, N–Z on shard 2) | Time-series or ordered data where range scans are common | Hotspot risk if writes concentrate on one range (e.g., monotonically increasing IDs) |
| **Hash-Based Sharding** | Key is hashed and mapped to a shard via modulo or similar | Uniform distribution of writes when range queries are not needed | Cross-shard range queries become scatter-gather; adding shards requires rehashing |
| **Consistent Hashing** | Keys and shards are placed on a virtual ring; each key is owned by the nearest shard clockwise | Dynamic shard membership (add/remove nodes with minimal data movement) | Implementation complexity; "hot" virtual nodes need replication or virtual node multiplication |
| **Directory-Based Sharding** | A lookup service maps keys to shards | Maximum flexibility; supports non-uniform partition sizes | Lookup service is a bottleneck and single point of failure if not replicated |

### Hotspot Risks
- Sequential or user-driven keys (user IDs, timestamps) concentrate writes on one shard.
- Mitigation: add a random prefix to the key, use virtual nodes, or pre-split hot key ranges.

---

## Backpressure

| Pattern | One-Line Description | When to Use | Key Trade-off |
|---|---|---|---|
| **Rate Limiting** (token bucket, leaky bucket) | Cap the number of requests a client or service can send in a time window | Protecting a downstream service from overload; enforcing per-tenant quotas | Legitimate bursts get rejected; requires coordination if enforced across multiple nodes |
| **Circuit Breaker** | Track failure rate; open the circuit (fast-fail all requests) when failure exceeds a threshold | Preventing cascade failures when a downstream service is degraded | False positives cause unnecessary outages; tuning thresholds is non-trivial |
| **Bulkhead** | Isolate resource pools (thread pools, connection pools) per downstream | Preventing one slow dependent from consuming all shared resources | Increases resource footprint; must size each pool independently |

---

## Read/Write Scaling

| Pattern | One-Line Description | When to Use | Key Trade-off |
|---|---|---|---|
| **Read Replicas** | Replicate the primary DB to one or more read-only followers | Read-heavy workloads where slightly stale reads are acceptable | Replication lag means followers can serve stale data; failover to replica requires reconfiguration |
| **CQRS** (Command Query Responsibility Segregation) | Separate the write model (commands) from the read model (queries), often backed by different data stores | Complex domains where read and write access patterns diverge significantly; event sourcing architectures | Two models to keep in sync; eventual consistency between write and read stores; higher operational complexity |
