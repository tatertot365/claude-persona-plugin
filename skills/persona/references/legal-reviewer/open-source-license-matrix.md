# Open Source License Matrix

A reference for commercial use, distribution obligations, copyleft strength, and license compatibility. Covers the most common licenses encountered in technology products and services.

---

## License Obligations Matrix

| License | Commercial Use | Modification Allowed | Distribution Requirements | Copyleft Type | Patent Grant |
|---|---|---|---|---|---|
| **MIT** | Yes | Yes | Include copyright notice and license text | None | No explicit grant |
| **Apache 2.0** | Yes | Yes | Include copyright notice, license text, NOTICE file (if present), and description of changes | None | Yes (explicit; also patent termination clause) |
| **BSD 2-Clause** | Yes | Yes | Include copyright notice and license text | None | No explicit grant |
| **BSD 3-Clause** | Yes | Yes | Include copyright notice, license text; no endorsement using project name | None | No explicit grant |
| **LGPL 2.1** | Yes | Yes | Allow users to re-link with modified library; provide source of library (not your app) | Weak (library-level) | No explicit grant |
| **LGPL 3.0** | Yes | Yes | Same as LGPL 2.1 + comply with GPL 3.0 additional permissions | Weak (library-level) | Yes (via incorporated GPL 3.0) |
| **GPL 2.0** | Yes | Yes | Must release complete corresponding source of any distributed work that includes GPL 2.0 code | Strong | No explicit grant |
| **GPL 3.0** | Yes | Yes | Must release complete corresponding source; anti-tivoization provisions; compatible with Apache 2.0 | Strong | Yes (explicit) |
| **AGPL 3.0** | Yes | Yes | Must release source to users of the software over a network (not just on distribution) | Network (strongest) | Yes (via GPL 3.0 base) |
| **MPL 2.0** | Yes | Yes | Modified MPL-licensed files must be released under MPL 2.0; proprietary files in same product permitted | Weak (file-level) | Yes (explicit) |
| **CC0** | Yes | Yes | No requirements (public domain dedication) | None | Yes (waiver of patent rights) |
| **CC-BY 4.0** | Yes | Yes | Attribute the original author | None | No explicit grant |
| **CC-BY-SA 4.0** | Yes | Yes | Attribute original author; derivative works must use same or compatible license | Weak (share-alike) | No explicit grant |

**Notes on Creative Commons:** CC licenses are designed for creative works, not software. CC0 is appropriate for data and is used in some software contexts (e.g., SQLite uses public domain dedication). CC-BY and CC-BY-SA are commonly used for documentation, datasets, and media assets — not for source code.

---

## License Compatibility Table

Can code under License A be combined with (incorporated into) code under License B and distributed as a single work?

| | MIT | Apache 2.0 | BSD 2/3 | LGPL 2.1 | LGPL 3.0 | GPL 2.0 | GPL 3.0 | AGPL 3.0 | MPL 2.0 |
|---|---|---|---|---|---|---|---|---|---|
| **MIT** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| **Apache 2.0** | Yes | Yes | Yes | Yes | Yes | **No** (patent clauses incompatible) | Yes | Yes | Yes |
| **BSD 2/3** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| **LGPL 2.1** | Yes | Yes | Yes | Yes | Upgrade to 3.0 | Yes | Yes | Yes | Yes |
| **LGPL 3.0** | Yes | Yes | Yes | — | Yes | No | Yes | Yes | Yes |
| **GPL 2.0** | Yes | **No** | Yes | Yes | No | Yes | Yes (one-way) | No | Yes (MPL 2.0 has compatibility clause) |
| **GPL 3.0** | Yes | Yes | Yes | Yes | Yes | Upgrade allowed | Yes | Yes | Yes |
| **AGPL 3.0** | Yes | Yes | Yes | Yes | Yes | No | Yes | Yes | Yes |
| **MPL 2.0** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |

**How to read this table:** "Yes" means the code can be combined into a single distributed work. "No" means there is an incompatibility — you cannot legally release a single combined work under both licenses. "Upgrade allowed" means the combination is possible if you release the combined work under the more permissive of the two licenses.

**Key incompatibilities to remember:**
- Apache 2.0 + GPL 2.0 = incompatible (Apache's patent termination and additional terms are considered "additional restrictions" under GPL 2.0 Section 6)
- Apache 2.0 + GPL 3.0 = compatible (GPL 3.0 was designed to be compatible with Apache 2.0)
- LGPL 2.1 is "or later" by default; most projects can be treated as compatible with GPL 2.0 and later

*When in doubt on a specific combination, consult the GNU license compatibility FAQ or legal counsel.*

---

## Practical Implications

### What "Copyleft" Means in Practice

**No copyleft (MIT, Apache 2.0, BSD):**
You can use, modify, incorporate, and redistribute the code — including in proprietary, closed-source products — with no obligation to release your own source code. You only need to include the original license text and copyright notice.

**Weak copyleft (LGPL, MPL 2.0):**
The copyleft "infects" only the LGPL/MPL-licensed files themselves, not your entire application.
- **LGPL:** If you use an LGPL library by dynamically linking it, you are generally fine — you do not have to release your application's source code. You must allow users to re-link with a modified version of the library, which in practice means distributing as a dynamic library rather than statically linking. If you statically link an LGPL library into your product, you must release enough object code for users to re-link.
- **MPL 2.0:** Only modified MPL-licensed files must be released. Your proprietary code in the same application is unaffected, as long as you keep the MPL files in separate files.

**Strong copyleft (GPL 2.0, GPL 3.0):**
If you distribute (ship) a product that contains or is a derivative work of GPL code, the entire combined work must be released under the GPL — including your proprietary code. This is the "viral" effect that makes GPL code unusable in most commercial closed-source products.

**Key distinction:** Copyleft is triggered by *distribution*, not by internal use. If you run GPL software internally (on your servers, for internal tools) and never distribute it to external parties, the GPL does not require you to release your source code.

### AGPL and SaaS: Why It Matters

AGPL 3.0 was specifically designed to close the "SaaS loophole" in the GPL.

Under GPL 2.0 and GPL 3.0, if you run software on a server and users access it over a network (SaaS model), you are not "distributing" the software — you are providing a service. The GPL's copyleft is not triggered. You can use GPL code in your SaaS product without releasing your source code.

**AGPL changes this.** Under AGPL 3.0 Section 13, if users interact with the software over a network, you must make the complete corresponding source code available to those users — even though you are not distributing a binary. This applies to any software that incorporates or is a derivative work of AGPL-licensed code.

**Practical consequence:** Using any AGPL-licensed library or component in a SaaS product means you must either:
1. Release the complete source code of your application (including proprietary code) to all users, or
2. Obtain a commercial license from the copyright holder (if they offer a dual-license), or
3. Remove the AGPL component and replace it with a permissively licensed alternative.

Many companies have formal policies prohibiting use of AGPL code in their products for exactly this reason. Notable AGPL-licensed software: MongoDB (until 4.0), GNU Affero tools, certain AI/ML libraries.

### MIT vs. Apache 2.0 for Commercial Use

Both MIT and Apache 2.0 are permissive licenses that allow commercial use without copyleft obligations. For most purposes, either works. The key differences:

| Factor | MIT | Apache 2.0 |
|---|---|---|
| **Explicit patent grant** | No | Yes — contributors grant a royalty-free patent license to users |
| **Patent retaliation** | No | Yes — if you sue a contributor for patent infringement related to the software, your Apache license terminates |
| **NOTICE file** | Not required | Required: must preserve NOTICE file if the project has one |
| **Compatibility with GPL 2.0** | Yes | No (see above) |
| **Compatibility with GPL 3.0** | Yes | Yes |
| **Length and detail** | Very short; easy to review | Longer; more precise legal language |

**Recommendation for commercial use:** Apache 2.0 is generally preferable to MIT because the explicit patent grant protects users from patent claims by contributors. The trade-off is GPL 2.0 incompatibility (relevant if you are incorporating GPL 2.0 code into the same product). If you are choosing a license for your own open source project, Apache 2.0 is the more legally robust choice.

### Copyleft and Static vs. Dynamic Linking

A common practical question is whether statically linking an LGPL library triggers stronger obligations than dynamically linking it.

- **Dynamic linking (shared library, .so/.dll):** Generally considered a "use" rather than creating a derivative work. LGPL allows this without triggering copyleft on your application.
- **Static linking:** The library's object code is baked into your binary. This is more likely to be treated as creating a combined or derivative work under LGPL, requiring you to provide object files sufficient for the user to re-link.

Note: The FSF's interpretation is more expansive than many courts have accepted, and there is genuine legal uncertainty here. For commercial products, the safest approach is dynamic linking for LGPL dependencies or obtaining legal advice if static linking is required.
