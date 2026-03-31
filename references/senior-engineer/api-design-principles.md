# API Design Principles — Quick Reference

## REST Principles

### Resource Naming
- Use **nouns**, not verbs. Resources are things, not actions.
- Use **plural** collection names: `/users`, `/orders`, `/invoices`.
- Nest to show ownership, but keep it shallow (max 2 levels deep).
- Use lowercase and hyphens, never underscores or camelCase in paths.

| Good | Bad |
|------|-----|
| `GET /users/42/orders` | `GET /getOrdersForUser?userId=42` |
| `POST /invoices` | `POST /createInvoice` |
| `DELETE /sessions/abc` | `POST /logout` |
| `PATCH /articles/7` | `PUT /updateArticle/7` |

### HTTP Verb Semantics

| Verb | Meaning | Idempotent | Safe |
|------|---------|-----------|------|
| `GET` | Retrieve a resource or collection | Yes | Yes |
| `POST` | Create a new resource, or trigger an action | No | No |
| `PUT` | Replace a resource entirely (upsert) | Yes | No |
| `PATCH` | Partially update a resource | No* | No |
| `DELETE` | Remove a resource | Yes | No |

*`PATCH` is not guaranteed idempotent by spec, but should be designed to be idempotent where possible.

### HTTP Status Codes

| Code | Name | When to Use |
|------|------|-------------|
| `200` | OK | Successful GET, PATCH, PUT, DELETE with a response body |
| `201` | Created | Successful POST that created a resource; include `Location` header |
| `202` | Accepted | Request accepted for async processing; not yet complete |
| `204` | No Content | Successful DELETE or action with no response body |
| `400` | Bad Request | Client sent invalid input (malformed JSON, missing required field) |
| `401` | Unauthorized | Not authenticated; include `WWW-Authenticate` header |
| `403` | Forbidden | Authenticated but not authorized for this resource |
| `404` | Not Found | Resource does not exist (or intentionally hidden) |
| `405` | Method Not Allowed | Verb not supported on this endpoint; include `Allow` header |
| `409` | Conflict | State conflict (duplicate resource, optimistic lock failure) |
| `410` | Gone | Resource existed but has been permanently deleted |
| `422` | Unprocessable Entity | Input is well-formed but fails domain validation |
| `429` | Too Many Requests | Rate limit exceeded; include `Retry-After` header |
| `500` | Internal Server Error | Unexpected server-side failure |
| `502` | Bad Gateway | Upstream service returned an invalid response |
| `503` | Service Unavailable | Server temporarily unavailable (overload, maintenance) |
| `504` | Gateway Timeout | Upstream service timed out |

**Key distinctions:**
- `400` = syntactically invalid. `422` = syntactically valid but semantically wrong.
- `401` = "who are you?". `403` = "I know who you are, but no."
- Avoid `404` for authorization failures when hiding resource existence matters (use `403` only if existence is already known to the requester).

---

## Versioning Strategies

### URL Versioning
```
/v1/users
/v2/users
```
**Pros:** Immediately visible, easy to route at the load balancer, easy to test in a browser.
**Cons:** Violates "a URL identifies a resource" — the version is part of the path, not the representation.

### Header Versioning
```
Accept: application/vnd.myapi.v2+json
```
or a custom header:
```
API-Version: 2024-01-15
```
**Pros:** Cleaner URLs; the resource path stays stable.
**Cons:** Harder to test directly in a browser; less obvious to consumers.

### When to Use Which
URL versioning is the pragmatic default for public APIs. Header versioning fits internal or SDK-driven APIs where clients are tightly controlled.

**Date-based versioning** (e.g., `API-Version: 2024-03-01`) works well for APIs with frequent incremental changes — it avoids the "what goes in v3 vs v4?" problem and provides a clear audit trail.

### When to Break Compatibility
Breaking changes justify a new version. Non-breaking changes do not. See the Backwards Compatibility section below.

### Deprecation Approach
1. Announce a sunset date at least 6 months in advance for public APIs.
2. Add a `Deprecation` and `Sunset` header to all responses from the deprecated version:
   ```
   Deprecation: true
   Sunset: Sat, 01 Jan 2026 00:00:00 GMT
   ```
3. Log which clients are still calling the deprecated version.
4. Send direct notification to active API consumers 30 and 7 days before sunset.
5. Return `410 Gone` (not `404`) after the sunset date.

---

## Backwards Compatibility

### Safe Changes (Non-Breaking)
For REST and gRPC, the following changes are always safe:

- Adding a new optional field to a response body
- Adding a new endpoint or RPC method
- Adding a new optional query parameter
- Adding a new enum value (with caveats — see below)
- Relaxing a constraint (e.g., increasing a max-length limit)
- Adding a new HTTP header

### Breaking Changes
These require a version bump:

| Change | Why It Breaks |
|--------|---------------|
| Removing or renaming a field | Clients reading that field get `null` or an error |
| Changing a field's type | Deserialization fails |
| Changing URL structure | Existing bookmarks/integrations break |
| Making an optional field required | Existing valid requests become invalid |
| Changing error response structure | Error-handling code breaks |
| Removing or renaming an enum value | Clients with exhaustive enum handling break |
| Changing authentication scheme | All clients must update at once |

**gRPC-specific:** Never re-use a field number even after removing a field. Mark removed fields as `reserved`.

**New enum values** are technically safe on the wire but breaking in practice if clients use exhaustive switch/match statements. Treat them as breaking unless your contract explicitly says unknown enum values should be treated as a default.

### Robustness Principle (Postel's Law)
Be conservative in what you send, liberal in what you accept. Ignore unknown fields in incoming requests; don't fail on unexpected future fields.

---

## Error Response Design

A well-structured error payload gives clients enough information to handle the error programmatically without exposing internals.

### Recommended Structure
```json
{
  "error": {
    "code": "INVALID_PAYMENT_METHOD",
    "message": "The payment method provided has expired.",
    "request_id": "req_4kJ9mXp2aQ",
    "details": [
      {
        "field": "card.expiry",
        "issue": "Date is in the past",
        "provided": "01/23"
      }
    ],
    "documentation_url": "https://docs.example.com/errors/INVALID_PAYMENT_METHOD"
  }
}
```

### Field Guidance

| Field | Required | Notes |
|-------|----------|-------|
| `code` | Yes | Machine-readable string constant. Use SCREAMING_SNAKE_CASE. Never change once published. |
| `message` | Yes | Human-readable explanation. OK to change wording. Not for parsing. |
| `request_id` | Yes | Unique ID for this request. Critical for support and debugging. |
| `details` | No | Array of per-field or per-issue breakdowns. Essential for `400`/`422` errors. |
| `documentation_url` | Recommended | Link to explanation and resolution steps. |

**Do not expose:** Stack traces, internal service names, SQL error messages, or internal IDs in error responses to external clients.

**Consistency matters:** Use the same structure for every error. If `4xx` errors have a different shape than `5xx` errors, clients must handle both.

---

## Pagination

### Offset-Based Pagination
```
GET /articles?offset=40&limit=20
```
**How it works:** Skip the first N records, return the next M.

**Pros:** Simple to implement and understand. Can jump to an arbitrary page.
**Cons:** Results shift if items are inserted or deleted between pages ("page drift"). Expensive on large datasets — the database must count and skip rows.

### Cursor-Based Pagination
```
GET /articles?cursor=eyJpZCI6NDJ9&limit=20
```
**How it works:** The server returns an opaque cursor pointing to the last item seen. The next request passes the cursor to continue from that point.

**Pros:** Stable — inserts/deletes don't cause duplicate or skipped items. Efficient — the cursor encodes a position the index can use directly.
**Cons:** Cannot jump to an arbitrary page. Cursors expire (usually 24–48 hours). Slightly more complex to implement.

### When to Use Each

| Use offset when... | Use cursor when... |
|--------------------|--------------------|
| Dataset is small and stable | Dataset is large or frequently updated |
| Users need "go to page N" | You're building infinite scroll or a feed |
| Simple admin interfaces | Real-time or near-real-time data |

**Response envelope for pagination:**
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6NjJ9",
    "has_more": true
  }
}
```

---

## Idempotency

**Definition:** An operation is idempotent if performing it multiple times produces the same result as performing it once. The final state is the same regardless of how many times the request was sent.

### Which Operations Must Be Idempotent

| Method | Idempotent? | Notes |
|--------|-------------|-------|
| `GET` | Yes | By definition — reads have no side effects |
| `PUT` | Yes | Full replacement is always idempotent |
| `DELETE` | Yes | Deleting a deleted resource returns `404` or `204` — both acceptable |
| `POST` | No (by default) | Requires explicit idempotency key support |
| `PATCH` | Design-dependent | Should be designed idempotent; avoid increment-style patches |

### Implementing Idempotency Keys

For `POST` requests (payments, order creation, emails, etc.), clients send a unique key with the request:

```
POST /charges
Idempotency-Key: a8098c1a-f86e-11da-bd1a-00112444be1e
```

**Server behavior:**
1. On first receipt: process the request, store the response keyed on the idempotency key (with a TTL, typically 24 hours).
2. On duplicate receipt (same key): return the stored response without reprocessing.
3. If the first request is still in flight: return `409 Conflict` or wait and return the result.

**Key requirements for clients:**
- Keys must be unique per distinct intended operation (use UUID v4).
- Do not reuse keys across different operations.
- Retry with the same key on network error or timeout — this is the point.

**Storage:** Store idempotency records in a durable, consistent store (not an in-memory cache). The record must survive server restarts.
