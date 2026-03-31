# CWE Quick Reference — Application Security Code Review

~25 most commonly encountered CWEs in application security code reviews, grouped by category.

Source: https://cwe.mitre.org/

---

## Injection

| CWE ID | Name | Description | What to look for in code |
|--------|------|-------------|--------------------------|
| CWE-89 | SQL Injection | User-controlled input is incorporated into a SQL query without parameterization. | String concatenation or interpolation in SQL queries; raw use of ORM methods that accept arbitrary query strings (e.g., `where(params[:filter])`). |
| CWE-79 | Cross-Site Scripting (XSS) | Untrusted data is rendered in a web page without proper escaping, executing attacker-controlled scripts in other users' browsers. | Template output without escaping (e.g., `innerHTML =`, `dangerouslySetInnerHTML`, `{!! $var !!}` in Blade, `| safe` in Jinja2); `document.write()` with user data. |
| CWE-78 | OS Command Injection | User-controlled input is passed to a system shell command without sanitization. | Calls to `exec()`, `system()`, `popen()`, `subprocess.call(shell=True)`, `Runtime.exec()` with any user-supplied string component. |
| CWE-917 | Expression Language Injection | User input is evaluated as an expression in a server-side template or EL engine, allowing arbitrary code execution. | User input passed to template engines (`Jinja2.from_string(user_input)`, Spring EL `#{userInput}`, Thymeleaf fragment expressions). |
| CWE-643 | XPath Injection | User-supplied data is embedded in an XPath query, allowing manipulation of XML document traversal logic. | String-concatenated XPath expressions using request parameters; look for `xpath.evaluate()` or similar with unsanitized input. |

---

## Memory Safety

| CWE ID | Name | Description | What to look for in code |
|--------|------|-------------|--------------------------|
| CWE-787 | Out-of-bounds Write | A write operation targets memory outside the bounds of the intended buffer, enabling memory corruption. | `strcpy`, `sprintf`, `gets` in C/C++; manual pointer arithmetic without bounds checks; fixed-size array writes indexed by user-controlled values. |
| CWE-125 | Out-of-bounds Read | A read operation accesses memory before the start or past the end of a buffer, potentially leaking sensitive memory contents. | Array indexing with user-controlled index lacking range validation; `memcpy`/`strncpy` with length derived from untrusted input. |
| CWE-416 | Use After Free | Memory is accessed after it has been freed, which may allow an attacker to control program behavior via heap manipulation. | Pointer reuse after `free()`; shared ownership without clear lifetimes in C/C++; review destructor and cleanup paths for dangling references. |
| CWE-476 | NULL Pointer Dereference | A pointer that may be null is dereferenced without a null check, causing a crash or in some contexts enabling exploitation. | Return values from allocation or lookup functions used immediately without null checks; optional/nullable types dereferenced without guards. |
| CWE-120 | Buffer Copy Without Checking Size | `strcpy` and similar functions copy into a buffer without verifying the source fits, causing a classic stack/heap overflow. | Any use of `strcpy`, `strcat`, `gets`, `scanf("%s")` in C/C++; prefer `strncpy`, `strlcpy`, or C++ `std::string`. |

---

## Authentication & Access Control

| CWE ID | Name | Description | What to look for in code |
|--------|------|-------------|--------------------------|
| CWE-284 | Improper Access Control | The system does not restrict access to a resource correctly, allowing unauthorized users to read, modify, or execute it. | Missing authorization checks before accessing resources by ID; relying solely on UI-level hiding; no role/permission verification in controller or service layer. |
| CWE-285 | Improper Authorization | Authorization logic is flawed or bypassable — distinct from missing checks, the checks present do not correctly enforce policy. | Authorization based on client-supplied data (e.g., role in JWT body without signature verification); logic errors in permission evaluation (OR vs AND); parameter tampering that bypasses guards. |
| CWE-287 | Improper Authentication | The system does not adequately prove the identity of an actor, allowing authentication bypass. | Absent or skippable authentication middleware; authentication based on IP or hostname alone; comparing hashed vs. plaintext values incorrectly. |
| CWE-306 | Missing Authentication for Critical Function | A critical operation is reachable without any authentication check. | Admin, delete, export, or payment endpoints with no `@auth`, `require_login`, or equivalent decorator/middleware. |
| CWE-269 | Improper Privilege Management | Privileges are granted or retained beyond what is needed, or privileges are not dropped after a privileged operation completes. | Long-lived admin sessions; processes running as root unnecessarily; failure to drop privileges after performing a privileged operation; no separation between user and admin roles at the code level. |
| CWE-798 | Use of Hard-coded Credentials | The product contains hard-coded passwords, API keys, or cryptographic keys embedded in source code. | String literals matching patterns like `password =`, `api_key =`, `secret =`, `token =` in source or config files committed to version control; Base64-encoded strings in code. |

---

## Cryptography

| CWE ID | Name | Description | What to look for in code |
|--------|------|-------------|--------------------------|
| CWE-327 | Use of a Broken or Risky Cryptographic Algorithm | The code uses a known-weak algorithm (MD5, SHA-1, DES, RC4, ECB mode) for a security-sensitive purpose. | Imports/references to `MD5`, `SHA1`, `DES`, `RC2`, `RC4`; AES used in `ECB` mode; RSA keys smaller than 2048 bits. |
| CWE-330 | Use of Insufficiently Random Values | Cryptographic operations (key generation, token creation, nonce selection) use a non-cryptographically-secure random source. | `Math.random()`, `rand()`, `Random()` (Java), `random.random()` (Python) used for security tokens, session IDs, or crypto nonces — use `SecureRandom`, `secrets`, `crypto.randomBytes()` instead. |
| CWE-326 | Inadequate Encryption Strength | Key lengths or algorithm parameters are too weak to resist brute-force attacks with current compute. | RSA < 2048 bits, EC < 224 bits, AES-128 in contexts requiring long-term secrecy, hardcoded short symmetric keys. |
| CWE-321 | Use of Hard-coded Cryptographic Key | A cryptographic key is embedded directly in source code, making it available to anyone with code access and impossible to rotate without a code change. | `key = "supersecretkey123"`, hardcoded IV/salt values, or keys stored in constants rather than loaded from a secrets manager or environment variable. |

---

## Input Validation

| CWE ID | Name | Description | What to look for in code |
|--------|------|-------------|--------------------------|
| CWE-20 | Improper Input Validation | The product receives input but does not validate or validates incorrectly that the input has the properties required for safe processing. | Missing type checks, range checks, or format validation before using input in business logic; reliance on client-side validation only; absence of server-side schema validation. |
| CWE-22 | Path Traversal | User-supplied input is used to construct a file path without neutralizing `../` sequences, allowing access to files outside the intended directory. | `open(base_dir + user_input)` or `File.new(root + filename)` without canonicalization; look for `os.path.join`, `Paths.get`, `File()` using any user-supplied string component. |
| CWE-601 | Open Redirect | A web application redirects users to a URL specified in an unvalidated request parameter, enabling phishing attacks. | `response.redirect(request.params.next)` or `Location: #{params[:url]}` without validating the destination against an allow-list of trusted domains. |
| CWE-434 | Unrestricted Upload of File with Dangerous Type | The application allows users to upload files without validating type, enabling upload of server-executable files (PHP, JSP, etc.). | File upload handlers that check only the client-supplied MIME type or file extension without server-side content-type inspection; uploads stored in web-accessible directories. |

---

## Error Handling

| CWE ID | Name | Description | What to look for in code |
|--------|------|-------------|--------------------------|
| CWE-209 | Generation of Error Message Containing Sensitive Information | Error messages or stack traces returned to the user contain internal details (stack traces, SQL queries, file paths, version info) that aid attackers. | `e.printStackTrace()` or unhandled exceptions propagating to HTTP responses; debug mode enabled in production (`DEBUG=True`, `display_errors=On`); raw database error messages surfaced to the client. |
| CWE-390 | Detection of Error Condition Without Action | The code detects an error but ignores it (empty catch block, unchecked return value), leaving the application in an undefined or insecure state. | Empty `catch {}` or `except: pass` blocks; ignored return values from security-sensitive functions (e.g., ignored result of `chmod()`, unchecked authentication call return code). |
