# OWASP Top 10 (2021) — Quick Reference

Source: https://owasp.org/Top10/

---

## A01:2021 — Broken Access Control

**What it is:** Users can act outside their intended permissions — accessing other users' data, elevating privileges, or reaching admin functions.

**Attack example:** An authenticated user changes the URL parameter from `/account?id=1234` to `/account?id=1235` and reads another user's account details (IDOR).

**Key mitigations:**
- Enforce access control server-side on every request; never rely on client-supplied roles or flags.
- Deny by default — explicitly grant access rather than blocking specific cases.
- Log access control failures and alert on repeated violations.

---

## A02:2021 — Cryptographic Failures

**What it is:** Sensitive data (passwords, PII, financial data) is exposed due to weak, missing, or misconfigured cryptography.

**Attack example:** An application stores passwords using MD5 without salting; an attacker who obtains the database cracks the hashes with a precomputed rainbow table in minutes.

**Key mitigations:**
- Use modern, vetted algorithms: Argon2/bcrypt for passwords, AES-256-GCM for symmetric encryption, TLS 1.2+ for data in transit.
- Never store sensitive data you don't need; classify data and apply protections based on sensitivity.
- Disable deprecated protocols (SSL, TLS 1.0/1.1) and weak cipher suites.

---

## A03:2021 — Injection

**What it is:** Untrusted data is sent to an interpreter (SQL, OS shell, LDAP, etc.) as part of a command or query, changing the command's intended logic.

**Attack example:** A login form sends `username = ' OR '1'='1` — the resulting SQL query returns all rows and bypasses authentication.

**Key mitigations:**
- Use parameterized queries / prepared statements for all database calls; never concatenate user input into queries.
- Validate and allow-list input on the server side.
- Apply least-privilege database accounts so a successful injection has limited blast radius.

---

## A04:2021 — Insecure Design

**What it is:** Security flaws baked into the architecture or business logic from the start — problems that cannot be fixed by secure implementation alone.

**Attack example:** A password-reset flow uses a 4-digit numeric PIN sent by SMS; an attacker can brute-force all 10,000 possibilities with no rate limiting and take over any account.

**Key mitigations:**
- Integrate threat modeling early in design; use security design patterns and reference architectures.
- Establish secure design principles (least privilege, separation of duties, fail-safe defaults) as non-functional requirements.
- Review business logic flows explicitly for abuse cases, not just functional correctness.

---

## A05:2021 — Security Misconfiguration

**What it is:** Systems deployed with insecure defaults, unnecessary features enabled, default credentials unchanged, or overly permissive cloud/container settings.

**Attack example:** A cloud storage bucket is left publicly readable; an attacker enumerates it and downloads customer PII and internal API keys.

**Key mitigations:**
- Build and enforce a hardened baseline configuration for all environments; use infrastructure-as-code to make deviations detectable.
- Disable or remove all default credentials, unnecessary ports, services, and features.
- Automate configuration scanning (e.g., cloud security posture management tools) and review security headers on every deployment.

---

## A06:2021 — Vulnerable and Outdated Components

**What it is:** Using libraries, frameworks, or other components with known vulnerabilities that attackers can exploit.

**Attack example:** An application runs an unpatched version of Log4j 2.x; an attacker sends a crafted log message triggering Log4Shell (CVE-2021-44228) and achieves remote code execution.

**Key mitigations:**
- Maintain an accurate Software Bill of Materials (SBOM) and subscribe to vulnerability feeds for every dependency.
- Automate dependency scanning (Dependabot, Snyk, OWASP Dependency-Check) in CI/CD pipelines.
- Have a patch policy — define acceptable time-to-remediate windows for critical vs. high vs. medium CVEs.

---

## A07:2021 — Identification and Authentication Failures

**What it is:** Weaknesses in authentication or session management that allow attackers to compromise passwords, keys, or sessions and assume other users' identities.

**Attack example:** An application allows unlimited login attempts with no lockout; an attacker uses a credential-stuffing tool with a breached password list and compromises thousands of accounts.

**Key mitigations:**
- Implement multi-factor authentication (MFA); use phishing-resistant options (FIDO2/WebAuthn) where possible.
- Enforce strong password policies and check new passwords against known-breached password lists (e.g., Have I Been Pwned).
- Use secure, server-side session management with properly configured expiry, rotation on privilege change, and invalidation on logout.

---

## A08:2021 — Software and Data Integrity Failures

**What it is:** Code and infrastructure updates applied without verifying integrity, including insecure deserialization and CI/CD pipeline compromise.

**Attack example:** A build pipeline pulls a dependency from a public package registry; an attacker publishes a malicious package with the same name as an internal package (dependency confusion), which gets pulled and executed on build servers.

**Key mitigations:**
- Use signed artifacts and verify signatures before use (e.g., Sigstore, signed container images).
- Pin dependencies to specific verified hashes, not floating version ranges.
- Restrict who can modify CI/CD pipelines and review pipeline definitions as rigorously as application code.

---

## A09:2021 — Security Logging and Monitoring Failures

**What it is:** Insufficient logging, monitoring, and alerting means breaches go undetected, or detection is too slow to limit damage.

**Attack example:** An attacker performs a slow, low-volume credential-stuffing attack over two weeks; because failed login events aren't logged or aggregated, the compromise of 50,000 accounts is only discovered when customers report it.

**Key mitigations:**
- Log authentication events, access control failures, input validation failures, and admin actions with sufficient context (timestamp, user ID, IP, action).
- Feed logs into a SIEM with alerting on anomalies; test that alerts fire.
- Protect logs from tampering; store them out-of-band so an attacker who compromises the app cannot erase their tracks.

---

## A10:2021 — Server-Side Request Forgery (SSRF)

**What it is:** An attacker can induce the server to make HTTP (or other protocol) requests to an arbitrary destination, including internal services not reachable from outside.

**Attack example:** An application fetches a user-supplied URL to generate a preview. An attacker submits `http://169.254.169.254/latest/meta-data/iam/security-credentials/` and retrieves AWS instance credentials from the cloud metadata service.

**Key mitigations:**
- Validate and restrict outbound request destinations using an allow-list of approved domains/IP ranges; block requests to RFC-1918 private ranges and link-local addresses.
- Disable URL redirects for server-side fetch operations, or re-validate the destination after redirect.
- Use a dedicated egress proxy so all outbound traffic is inspectable and controllable.
