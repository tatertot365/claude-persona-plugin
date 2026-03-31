# CAP Theorem & Distributed Consistency Models — Reference

---

## CAP Theorem

In any distributed system, you can guarantee at most **two** of the three following properties simultaneously:

| Property | What It Means |
|---|---|
| **Consistency (C)** | Every read receives the most recent write or an error — all nodes see the same data at the same time |
| **Availability (A)** | Every request receives a non-error response, though it may not contain the latest data |
| **Partition Tolerance (P)** | The system continues operating even when network partitions drop or delay messages between nodes |

**The practical reality:** Network partitions are unavoidable in distributed systems. So the real choice is: when a partition happens, do you sacrifice **Consistency** or **Availability**?

### CP Systems (Consistency over Availability)
When a partition occurs, the system refuses requests rather than return potentially stale data.

| System | Why CP |
|---|---|
| **ZooKeeper** | Coordinator elections require consensus; an unavailable quorum is safer than split-brain |
| **HBase** | Strong consistency for reads/writes; sacrifices availability during region server failures |
| **etcd** | Used for distributed locks and config; correctness is more important than uptime |

### AP Systems (Availability over Consistency)
When a partition occurs, the system keeps serving requests but nodes may disagree on current state.

| System | Why AP |
|---|---|
| **Cassandra** (default tuning) | Designed for high write availability; eventual consistency via hinted handoff and read repair |
| **DynamoDB** (eventual consistency reads) | Availability-first; offers optional strong consistency at higher cost |
| **CouchDB** | Multi-master replication with conflict resolution; prioritizes availability and offline operation |

> **Note:** CAP is a useful mental model, but most modern databases offer tunable consistency. The real-world question is usually: "What are the consistency/latency trade-offs at each read/write quorum setting?"

---

## Consistency Models

Ordered from strongest to weakest guarantee:

| Model | Plain-Language Description | Example System/Protocol |
|---|---|---|
| **Linearizability (Strong)** | Every operation appears to take effect at a single instant between its invocation and response. Any read reflects all prior writes, globally. | Google Spanner (TrueTime), etcd, ZooKeeper |
| **Sequential Consistency** | All operations appear to execute in some total order, and each individual process's operations appear in program order — but there is no global real-time ordering requirement. | Early distributed shared memory systems; some in-memory databases |
| **Causal Consistency** | Writes that are causally related (write B depends on read A) are seen in order by all nodes. Concurrent writes may be seen in different orders. | MongoDB (causal sessions), COPS distributed store |
| **Eventual Consistency** | Given no new writes, all replicas will converge to the same value — eventually. No guarantee on when or what you'll read in the interim. | Cassandra (default), DynamoDB (eventual reads), DNS |
| **Read-Your-Writes** | A special case: a client is guaranteed to see its own most recent write. Other clients may still see stale data. | Sticky sessions in web apps, DynamoDB with conditional reads |

---

## Common Consistency Trade-offs in Practice

### Reads vs. Writes
- **Strengthening read consistency** (e.g., requiring all replicas to agree) increases read latency and reduces availability.
- **Weakening write consistency** (e.g., async replication) speeds up writes but risks data loss on failure.

### Latency vs. Consistency
- Strong consistency requires coordination across nodes (consensus round-trips). Every hop adds latency.
- Eventual consistency allows local reads/writes — latency is low, but clients must tolerate stale data.

### Quorum Trade-offs (for systems like Cassandra/DynamoDB)
Given replication factor `N`, write quorum `W`, read quorum `R`:
- **Strong consistency:** `W + R > N` (e.g., N=3, W=2, R=2)
- **High availability:** lower W and R, but reads may be stale
- Common default (N=3, W=1, R=1) maximizes throughput at the cost of consistency

---

## Decision Guide

> "If I need X, which consistency model should I use?"

| You Need | Use This Model | Why |
|---|---|---|
| Correct distributed locks or leader election | **Linearizability** | Any weaker model risks two nodes believing they hold the lock simultaneously |
| Financial ledgers, inventory counts where double-spend must be prevented | **Linearizability** or **Strong Consistency** | Incorrect reads lead to real-world money or stock discrepancies |
| Collaborative editing with causally related operations | **Causal Consistency** | Preserves "replied after reading" ordering without the cost of global coordination |
| Social feeds, recommendation caches, DNS-like lookup | **Eventual Consistency** | Staleness is acceptable; availability and throughput matter more |
| A user viewing their own profile after updating it | **Read-Your-Writes** | Users notice if their own change disappears; other users seeing stale data is fine |
| Cross-region replication where latency must stay low | **Eventual Consistency** | Synchronous cross-region coordination adds hundreds of milliseconds per write |
| Shopping cart / counter that must not lose data but can tolerate brief staleness | **Causal or Eventual + Conflict Resolution** | CRDTs or last-write-wins policies handle merge without coordination overhead |
