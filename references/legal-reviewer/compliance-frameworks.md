# Compliance Frameworks: GDPR, CCPA, HIPAA, and SOC 2

A side-by-side reference for technology companies navigating data privacy and security compliance. Includes gap assessment questions and DPA requirements.

---

## Framework Comparison

### Applicability

| | GDPR | CCPA / CPRA | HIPAA | SOC 2 |
|---|---|---|---|---|
| **Full Name** | General Data Protection Regulation | California Consumer Privacy Act / California Privacy Rights Act | Health Insurance Portability and Accountability Act | System and Organization Controls 2 |
| **Jurisdiction** | European Union (+ EEA) | California, USA | United States (federal) | United States (industry standard) |
| **Who Must Comply** | Any organization processing personal data of EU/EEA residents, regardless of where the org is located | For-profit businesses meeting any one of: (1) $25M+ gross revenue, (2) buy/sell/receive data of 100,000+ CA consumers/households, or (3) derive 50%+ revenue from selling CA personal data | "Covered entities" (health plans, healthcare clearinghouses, most healthcare providers) and their "business associates" | Any service organization that stores, processes, or transmits customer data; required by many enterprise customers |
| **Mandatory?** | Yes (law) | Yes (law, for qualifying businesses) | Yes (law, for covered entities and BAs) | No (market-driven; required by enterprise contracts) |

---

### Key Obligations

| Obligation | GDPR | CCPA / CPRA | HIPAA | SOC 2 |
|---|---|---|---|---|
| **Legal Basis for Processing** | Required: must identify lawful basis (consent, contract, legitimate interest, etc.) | N/A — no lawful basis requirement; opt-out model | Required: TPO (Treatment, Payment, Operations) or authorization | N/A |
| **Privacy Notice** | Required: must be provided at or before collection | Required: "Notice at Collection" at point of collection | Required: Notice of Privacy Practices (NPP) | N/A |
| **Data Minimization** | Required: collect only what is necessary | Required under CPRA | Required: minimum necessary standard | N/A |
| **Security Requirements** | Required: "appropriate technical and organizational measures" | Required: "reasonable security" | Required: Administrative, Physical, Technical Safeguards (detailed specifications) | Required: Documented controls across Trust Service Criteria |
| **Vendor Management** | Required: DPAs with all processors | Required: contracts with service providers | Required: Business Associate Agreements (BAAs) with all BAs | Required: vendor/subprocessor controls |
| **Data Retention** | Required: retention limits; delete when no longer necessary | Required: retention limits (CPRA) | Required: retain for 6 years from creation or last effective date | Required: documented retention policies |
| **Cross-Border Transfers** | Restricted: requires adequacy decision, SCCs, or BCRs | No equivalent restriction | No equivalent restriction | N/A |
| **DPO/Privacy Officer** | Required for certain organizations (large-scale processing, systematic monitoring, sensitive data) | No DPO requirement | Required: Privacy Officer and Security Officer | Required: designated security responsible party |

---

### Individual Rights

| Right | GDPR | CCPA / CPRA | HIPAA | SOC 2 |
|---|---|---|---|---|
| **Right to Know / Access** | Yes (Art. 15) | Yes | Yes (limited) | N/A |
| **Right to Delete** | Yes (Art. 17, with exceptions) | Yes (with exceptions) | Limited | N/A |
| **Right to Portability** | Yes (Art. 20) | Yes (CPRA) | Limited (right to electronic copy) | N/A |
| **Right to Correct** | Yes (Art. 16) | Yes (CPRA) | Yes | N/A |
| **Right to Object / Opt-Out** | Yes (Art. 21; opt-out of legitimate interest processing) | Yes (opt-out of sale/sharing of PI) | Limited | N/A |
| **Right to Restrict Processing** | Yes (Art. 18) | No equivalent | No equivalent | N/A |
| **Non-Discrimination** | N/A | Yes (cannot be denied service for exercising rights) | N/A | N/A |
| **Response Deadline** | 1 month (extendable to 3) | 45 days (extendable by additional 45) | 30 days (extendable to 60) | N/A |

---

### Data Categories Covered

| | GDPR | CCPA / CPRA | HIPAA | SOC 2 |
|---|---|---|---|---|
| **General Personal Data** | Yes: any information relating to an identified/identifiable natural person | Yes: information that identifies, relates to, or could reasonably be linked to a consumer or household | Only if it is PHI (linked to health + individual identity) | Customer data entrusted to the service org |
| **Special / Sensitive Categories** | Extra protections: health, biometric, genetic, racial/ethnic, political, religious, sexual orientation data | "Sensitive PI" (CPRA): SSN, financial account, precise geolocation, health, sex life, immigration, racial/ethnic, biometric | All PHI is inherently sensitive | Varies by applicable Trust Service Criteria |
| **Employee Data** | Yes (employees are data subjects) | Yes (California employees have rights under CPRA) | No (unless acting as covered entity for employee health benefits) | Customer data only; employee data handled separately |
| **B2B / Business Contact Data** | Yes (individuals, not companies) | Limited exemption for B2B contacts (narrowed by CPRA) | No | N/A |

---

### Breach Notification Requirements

| | GDPR | CCPA / CPRA | HIPAA | SOC 2 |
|---|---|---|---|---|
| **Notify Regulator** | Yes: within 72 hours of awareness (if risk to individuals) | No regulatory notification requirement under CCPA itself; California AG may investigate | Yes: within 60 days of discovery (for breaches affecting 500+ individuals in a state, also notify HHS and media) | N/A |
| **Notify Individuals** | Yes: without undue delay if high risk to individuals | Yes: if unencrypted PI is involved (California breach notification law, separate from CCPA) | Yes: within 60 days of discovery | N/A |
| **Trigger** | Breach of security leading to accidental/unlawful destruction, loss, alteration, or unauthorized disclosure of personal data | Unauthorized access/disclosure of unencrypted PI | Acquisition, access, use, or disclosure of PHI not permitted under HIPAA Privacy Rule | Contractual obligation to notify customers |
| **Threshold** | Risk-based (notify regulator if any risk; notify individuals only if high risk) | Any unauthorized access of unencrypted PI (California law) | Presumed reportable unless low probability of compromise | Per contract terms |

---

### Penalties

| | GDPR | CCPA / CPRA | HIPAA | SOC 2 |
|---|---|---|---|---|
| **Maximum Fine** | Higher of €20M or 4% of global annual revenue (most serious); €10M or 2% (other violations) | Up to $7,500 per intentional violation; $2,500 per unintentional | $100–$50,000 per violation; annual cap $1.93M per violation category | No regulatory penalties; loss of certification and customer contracts |
| **Private Right of Action** | No direct GDPR private action; member states may allow | Yes: $100–$750 per consumer per incident for data breaches (statutory damages without proof of harm) | No private right of action | N/A |
| **Enforcement Body** | Data Protection Authorities (DPAs) in each EU member state | California Privacy Protection Agency (CPPA) + California AG | HHS Office for Civil Rights (OCR) | AICPA / independent auditors |

---

## Gap Assessment Guide

Use these questions to quickly assess whether a company is compliance-ready for each framework.

### GDPR Gap Assessment
1. **Do you process personal data of any EU/EEA residents?** (If yes, GDPR applies regardless of your location.)
2. **Have you identified the lawful basis for each category of personal data processing you perform?** (Consent, contract, legitimate interest, legal obligation, vital interests, public task — each must be documented.)
3. **Do you have signed Data Processing Agreements with every vendor or subprocessor that handles EU personal data on your behalf?**
4. **Can you fulfill a data subject access request (DSAR) within 30 days?** (Do you have a process to locate all data for a specific individual across all systems?)
5. **Are cross-border data transfer mechanisms in place for any personal data moving outside the EU/EEA?** (SCCs, adequacy decision, BCRs.)
6. **Have you conducted a Data Protection Impact Assessment (DPIA) for any high-risk processing activities?** (Large-scale profiling, systematic monitoring, sensitive data processing.)

### CCPA / CPRA Gap Assessment
1. **Does your business meet any of the three thresholds that trigger CCPA applicability?** (Revenue, data volume, revenue from data sales.)
2. **Does your privacy policy disclose the categories of personal information collected, purposes of collection, and categories of third parties with whom PI is shared or sold?**
3. **Is there a clear mechanism for California consumers to opt out of the "sale or sharing" of their personal information?** (The "Do Not Sell or Share My Personal Information" link or equivalent.)
4. **Do you have a process to respond to consumer rights requests (access, delete, correct, portability) within 45 days?**
5. **Have you updated contracts with all service providers, contractors, and third parties to include the required CPRA provisions?** (Prohibition on selling/sharing data, limitation on use.)
6. **Do you honor Global Privacy Control (GPC) browser signals as an opt-out?** (Required under CPRA regulations.)

### HIPAA Gap Assessment
1. **Are you a covered entity or a business associate of one?** (If you handle, process, or store protected health information (PHI) on behalf of a covered entity, you are a BA.)
2. **Have you signed Business Associate Agreements (BAAs) with all of your covered entity clients, and with all subcontractors who handle PHI on your behalf?**
3. **Have you completed a Security Risk Assessment (SRA)?** (Required; must identify, assess, and implement safeguards for all risks to PHI.)
4. **Are all required Technical Safeguards implemented?** (Access controls, audit controls, integrity controls, transmission security/encryption.)
5. **Have you trained all workforce members on HIPAA policies and procedures within the last year?** (Required; must be documented.)
6. **Do you have documented Breach Notification policies and procedures, and have you tested your incident response plan?**

### SOC 2 Gap Assessment
1. **Have you defined and documented your system description, including system boundaries, infrastructure, and data flows?** (Required for every SOC 2 audit.)
2. **Do you have documented security policies covering access control, change management, risk assessment, and incident response?** (The Trust Services Criteria require policies, not just practices.)
3. **Is logical access to production systems controlled and reviewed?** (Principle of least privilege, access reviews at least annually, offboarding procedures.)
4. **Do you have a vendor/subprocessor management program?** (SOC 2 requires monitoring of third-party risk.)
5. **Are you collecting and retaining audit logs sufficient to detect and investigate security incidents?** (Logs must be protected and retained per your policy.)
6. **Have you completed an internal readiness assessment or gap assessment against the applicable Trust Services Criteria?** (Security criterion is required for all SOC 2; Availability, Confidentiality, Processing Integrity, Privacy are optional add-ons.)

---

## Data Processing Agreements (DPAs)

### When Is a DPA Required?

A DPA is required under GDPR whenever:

- A **controller** engages a **processor** to process personal data of EU/EEA individuals on its behalf
- The relationship is ongoing or involves access to EU personal data (even incidentally)
- You are a SaaS vendor with any EU customers (your customer is the controller; you are the processor)
- You engage subprocessors (cloud infrastructure, analytics tools, support platforms) who will access customer personal data

A DPA is also best practice (and often contractually required) for CCPA "Service Provider" relationships, though the CCPA calls this a "service provider contract" rather than a DPA.

**Rule of thumb:** If a vendor can access, store, or process any personal data on your behalf, you need a DPA.

### What a GDPR-Compliant DPA Must Contain

Under GDPR Article 28, a DPA between a controller and processor must specify:

| Required Provision | Description |
|---|---|
| **Subject matter and duration** | What personal data is being processed and for how long |
| **Nature and purpose of processing** | What operations will be performed and why |
| **Type of personal data** | Categories of data (e.g., contact data, usage data, health data) |
| **Categories of data subjects** | Who the individuals are (e.g., employees, customers, end users) |
| **Process only on controller instructions** | Processor may not process data for its own purposes or beyond what the controller directs |
| **Confidentiality obligations** | Persons authorized to process data must be bound by confidentiality |
| **Security measures** | Processor must implement appropriate technical and organizational measures (Art. 32) |
| **Subprocessor restrictions** | Processor must obtain controller's prior written authorization before engaging subprocessors; sub-DPAs required |
| **Data subject rights assistance** | Processor must assist controller in fulfilling DSAR obligations (access, deletion, portability, etc.) |
| **Audit rights** | Controller must be able to audit processor's compliance (directly or via third-party auditors) |
| **Deletion or return of data** | On termination, processor must delete or return all personal data |
| **Breach notification** | Processor must notify controller without undue delay (standard: within 24–72 hours of discovery) |
| **Record of processing activities** | Processor must maintain records of processing activities carried out on behalf of controller |

### Cross-Border Transfer Mechanisms to Include

If the processor is located outside the EU/EEA, or uses subprocessors outside the EU/EEA, the DPA must also address transfer mechanisms:

- **EU Standard Contractual Clauses (SCCs):** The 2021 EC SCCs are the most common mechanism; must be incorporated in full without modification
- **Adequacy Decision:** If the destination country has an adequacy decision (e.g., UK, Japan, Canada), SCCs may not be needed
- **Binding Corporate Rules (BCRs):** For intra-group transfers within a multinational; requires DPA approval
- **Transfer Impact Assessment (TIA):** Required alongside SCCs to assess whether the destination country's laws undermine the protections; must be documented
