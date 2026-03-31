# OWASP API Security Top 10 (2023) — Quick Reference

Source: https://owasp.org/API-Security/editions/2023/en/0x11-t10/

---

## API1:2023 — Broken Object Level Authorization (BOLA)

**What it is:** APIs fail to verify that the requesting user is authorized to access a specific object, allowing users to manipulate object IDs to reach data they don't own.

**Attack example:** `GET /api/orders/5501` returns an order belonging to another user because the API validates only that the caller is authenticated, not that they own order 5501.

**Key mitigations:**
- Re-validate ownership/permission on every object-level access, using the authenticated user's identity from the session — never trust a client-supplied resource ID alone.
- Prefer non-sequential, non-guessable IDs (UUIDs) to reduce enumeration risk (defense-in-depth, not a substitute for authorization checks).
- Write automated tests that explicitly verify cross-user access is denied.

---

## API2:2023 — Broken Authentication

**What it is:** Authentication mechanisms are implemented incorrectly or are missing, enabling attackers to compromise authentication tokens or assume other users' identities.

**Attack example:** An API issues JWT tokens signed with `alg: none`; an attacker strips the signature and forges a token claiming to be an admin user.

**Key mitigations:**
- Use battle-tested, standard authentication libraries and frameworks; never roll your own token validation.
- Enforce short token lifetimes, token rotation, and secure storage guidance for clients.
- Implement rate limiting and lockout on authentication endpoints to prevent brute-force and credential stuffing.

---

## API3:2023 — Broken Object Property Level Authorization

**What it is:** APIs expose object properties the caller shouldn't be able to read or write — combining what was previously called "Excessive Data Exposure" and "Mass Assignment" in the 2019 edition.

**Attack example:** A `PATCH /api/users/me` endpoint accepts any JSON field. An attacker sends `{"role": "admin"}` and the ORM blindly writes it to the database, elevating their privileges.

**Key mitigations:**
- Define explicit allow-lists of readable and writable properties per endpoint and role; never pass raw request bodies directly to ORM update methods.
- Return only the fields the caller is authorized to see — use response DTOs/serializers rather than returning full model objects.
- Treat mass-assignment frameworks (ActiveRecord `update_attributes`, Django `ModelForm`, etc.) with explicit attribute filtering (`permit`, `fields`).

---

## API4:2023 — Unrestricted Resource Consumption

**What it is:** APIs lack controls on the volume or size of requests, enabling denial-of-service attacks or disproportionate resource consumption that leads to operational cost or availability impact.

**Attack example:** A search API accepts a `page_size` parameter with no upper bound; an attacker queries `page_size=1000000`, forcing the server to load millions of rows per request and causing an outage.

**Key mitigations:**
- Enforce rate limits per client/user/IP on all API endpoints; return `429 Too Many Requests` with `Retry-After` headers.
- Cap all user-controlled size parameters (pagination limits, upload sizes, query depth for GraphQL).
- Set timeouts and resource limits at every layer (gateway, application, database query timeout).

---

## API5:2023 — Broken Function Level Authorization

**What it is:** APIs fail to enforce access control at the function/endpoint level, allowing lower-privileged users to invoke admin or privileged operations.

**Attack example:** An admin endpoint `DELETE /api/admin/users/{id}` is only hidden from the UI but not protected server-side; a regular user who discovers the URL can delete any account.

**Key mitigations:**
- Apply explicit authorization checks on every endpoint, including administrative and internal routes — security through obscurity is not sufficient.
- Group privileged endpoints under a separate path prefix with a dedicated middleware/guard (e.g., all admin routes require an `admin` role check).
- Regularly audit all API routes against the intended permission matrix; include this in security testing.

---

## API6:2023 — Unrestricted Access to Sensitive Business Flows

**What it is:** APIs expose business flows (purchasing, account creation, coupon redemption) without safeguards against automated abuse at scale.

**Attack example:** An e-commerce API allows adding unlimited items to a cart and completing checkout with no rate limiting; a scalper bot purchases entire limited-edition product inventory in seconds.

**Key mitigations:**
- Identify high-value business flows and apply appropriate friction: CAPTCHA, device fingerprinting, anomaly detection, or purchase quantity limits.
- Rate-limit sensitive flows at the business logic level (e.g., max 3 account creations per IP per hour), not just at the HTTP layer.
- Monitor for unusual usage patterns and have playbooks to throttle or block abusive clients.

---

## API7:2023 — Server Side Request Forgery (SSRF)

**What it is:** APIs fetch remote resources based on user-supplied URLs without sufficient validation, enabling attackers to redirect requests to internal services or cloud metadata endpoints.

**Attack example:** A webhook registration API accepts any URL; an attacker registers `http://10.0.0.50:8080/internal-admin` and the API server makes authenticated requests to the internal service on their behalf.

**Key mitigations:**
- Validate and allow-list permitted URL schemes, hosts, and port ranges; reject requests to private IP ranges (RFC 1918, 169.254.x.x, ::1).
- Perform DNS resolution server-side and re-validate the resolved IP against the allow-list (to prevent DNS rebinding).
- Route all outbound API-initiated traffic through an egress proxy with logging and filtering.

---

## API8:2023 — Security Misconfiguration

**What it is:** APIs are deployed with insecure defaults, misconfigured security headers, overly permissive CORS, or exposed debug/management endpoints.

**Attack example:** An API deployed to production still has `/swagger-ui` publicly accessible and debug logging enabled; an attacker uses the Swagger UI to enumerate all endpoints and their parameters, then reads database credentials from verbose error responses.

**Key mitigations:**
- Harden API gateways and frameworks: set restrictive CORS policies, disable debug endpoints and verbose error messages in production, apply security headers (`Strict-Transport-Security`, `X-Content-Type-Options`, etc.).
- Automate configuration validation as part of deployment pipelines.
- Ensure TLS is enforced everywhere and certificates are valid; reject plaintext HTTP connections.

---

## API9:2023 — Improper Inventory Management

**What it is:** Organizations lack visibility into all their API versions and exposed endpoints, leaving old, unpatched, or undocumented APIs reachable.

**Attack example:** An application migrated to `/api/v2/` but never decommissioned `/api/v1/`; the v1 endpoint still lacks the authorization fixes applied to v2, and attackers exploit it to bypass access controls.

**Key mitigations:**
- Maintain a current inventory of all APIs, versions, and environments (production, staging, dev); include this in the SBOM/asset register.
- Decommission old API versions on a defined schedule; enforce version sunset policies.
- Gate all API traffic through a central API gateway so undocumented/shadow APIs cannot be published without going through the inventory.

---

## API10:2023 — Unsafe Consumption of APIs

**What it is:** Applications consume third-party APIs with implicit trust, failing to validate responses, handle failures securely, or protect against malicious data from the upstream service.

**Attack example:** An application forwards addresses from a third-party geolocation API directly into a SQL query without sanitization; a compromised or malicious upstream API injects a SQL payload that the consuming application executes.

**Key mitigations:**
- Treat data from third-party APIs as untrusted input — validate, sanitize, and type-check all responses before using them.
- Use TLS and verify certificates when calling external APIs; do not trust self-signed certs in production.
- Evaluate the security posture of third-party APIs before integrating; establish contractual security requirements and monitor for upstream breaches.
