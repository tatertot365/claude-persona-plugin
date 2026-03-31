# Contract Review Checklist: Technology Agreements

A clause-by-clause reference for reviewing SaaS agreements, MSAs, NDAs, and SOWs. For each clause type: what to check, what a fair/standard version looks like, and red flags to escalate.

---

## 1. Scope of Services

### What to Check
- Is the scope defined with enough specificity that both parties have the same expectations?
- Are deliverables, timelines, acceptance criteria, and exclusions explicitly stated?
- Does the language create an obligation to achieve a result (e.g., "will provide") or just an obligation to try (e.g., "will use commercially reasonable efforts")?
- Is the scope fixed or can the vendor unilaterally change it?

### What's Standard / Fair
- Scope defined by reference to an exhibit, SOW, or product documentation
- Change order process for modifications (written change orders, signed by both parties)
- "Efforts" standard is acceptable for complex professional services; result obligations appropriate for SaaS uptime/functionality
- Any limits on what the vendor is NOT responsible for are explicit and reasonable

### Red Flags
- Scope defined only by a marketing brochure or URL (vendor can change webpage)
- No change order process — scope creep risk with no recourse
- Vendor reserves right to modify services with little or no notice
- Acceptance criteria absent for custom development work
- "As-is" or "beta" designations that strip all quality obligations

---

## 2. Term & Renewal

### What to Check
- What is the initial term length?
- Is there an auto-renewal clause? How long is the notice period to cancel?
- When does the renewal notice window open and close?
- What happens to pricing on renewal — does it auto-escalate?

### What's Standard / Fair
- Initial term of 12 months (SaaS) or project duration (SOW)
- Auto-renewal with 30–60 days written notice to cancel; 90 days is acceptable for enterprise
- Renewal at same price or with a capped escalation (e.g., CPI + 3%)
- Notice period aligned to budget/procurement cycles (renewal notice falling mid-quarter is workable)

### Red Flags
- Auto-renewal with a very short cancellation window (e.g., 10–15 days), especially if notice window opens and closes before typical procurement review
- Evergreen clauses that renew indefinitely with no natural off-ramp
- Price can increase by any amount on renewal with no cap
- Notice must be sent by certified mail (not email) — easy to miss and lose the window
- Multi-year lock-in without corresponding discounts or termination-for-convenience rights

---

## 3. Termination Rights

### What to Check
- Does either party have the right to terminate for convenience (without cause)?
- What triggers termination for cause? What is the cure period?
- What are the obligations on termination (wind-down, data return, payment for work in progress)?
- Are there any termination fees or clawbacks?

### What's Standard / Fair
- **Termination for convenience:** Customer should have the right to terminate on 30–90 days notice, potentially with a wind-down fee for remaining prepaid period
- **Termination for cause:** Material breach with 30-day cure period before termination is effective; immediate termination for insolvency, IP infringement, or data breach is reasonable
- Mutual termination rights (not just vendor rights)
- Data return/export window of 30–90 days post-termination at no charge

### Red Flags
- Only vendor has termination-for-convenience right
- No cure period for alleged breach (allows immediate termination with no chance to fix)
- Vendor can terminate for non-payment with no notice or cure period
- Termination fee equals full remaining contract value (not proportional)
- Data is deleted immediately on termination with no export window
- "Survival" clause that keeps restrictive obligations (e.g., non-compete) running for years post-termination

---

## 4. Payment & Invoicing

### What to Check
- Payment terms (net 30? net 15? due on receipt?)
- What triggers an invoice (calendar date, milestone, renewal)?
- Late payment interest rate and when it begins to accrue
- Dispute process for contested invoices — can payment be withheld for disputed amounts?
- Are there penalties or service suspensions for late payment?

### What's Standard / Fair
- Net 30 payment terms from invoice date (net 45 acceptable for large enterprises)
- Late interest at 1–1.5% per month or the legal rate (whichever is lower)
- Good-faith dispute process: disputed amounts withheld in writing while undisputed amounts are paid
- 30-day notice + opportunity to cure before service suspension for non-payment
- Invoices sent electronically to a designated billing contact

### Red Flags
- Net 10 or "due on receipt" with immediate suspension rights
- Late fees above 2% per month or flat penalties
- No dispute mechanism — must pay even contested invoices to avoid suspension
- Vendor can accelerate entire contract value if one payment is late
- Service suspension without advance notice
- Automatic price escalation clauses buried in invoicing terms

---

## 5. Liability Cap

### What to Check
- Is there a cap on each party's total liability?
- What is the cap amount relative to contract value?
- Are there carve-outs from the cap (IP infringement, data breach, willful misconduct)?
- Does the cap apply symmetrically to both parties, or only to the vendor?

### What's Standard / Fair
- **General liability cap:** 12 months of fees paid or payable in the prior 12 months — widely accepted as the market standard
- **Enhanced cap for specific claims:** 2x annual fees for data breach/privacy violations; uncapped for willful misconduct, gross negligence, fraud
- Mutual cap (applies to customer's indemnification obligations too)
- Consequential damages excluded for both parties (mutual waiver)

### Red Flags
- Cap set at a very low fixed number (e.g., $1,000 or $10,000) regardless of contract size
- No carve-outs — cap applies even to fraud or IP infringement
- Asymmetric cap: vendor capped at 1 month fees, customer capped at unlimited
- Consequential damages excluded only for vendor (customer exposure uncapped)
- Vendor limits liability for data breaches to the general cap — inadequate given regulatory exposure
- Cap applies to third-party claims, including IP infringement (extremely vendor-favorable)

---

## 6. Indemnification

### What to Check
- Who indemnifies whom, and for what?
- Is the indemnification mutual?
- What are the IP infringement indemnification obligations?
- Are there carve-outs for indemnitee's own negligence or misconduct?
- What are the procedural requirements to trigger indemnification (notice, control of defense)?

### What's Standard / Fair
- **Vendor indemnifies customer** for third-party IP infringement claims arising from the vendor's product (as delivered, not as modified by customer)
- **Customer indemnifies vendor** for claims arising from customer's data, customer's use in violation of AUP, or customer's modifications
- Indemnification procedures: prompt notice, indemnitor controls defense, indemnitee cooperates and has right to participate at own cost
- Carve-outs from vendor's IP indemnity: customer modifications, use with non-approved third-party products, use after notice of infringement

### Red Flags
- No IP infringement indemnification from vendor
- Indemnification is one-way (customer indemnifies vendor, but not vice versa)
- No carve-outs — vendor indemnifies even for customer's own negligence
- Indemnification triggers require indemnitor's sole control of defense without any indemnitee approval rights (including settlement)
- Settlements can be made that impose obligations on indemnitee without consent
- Indemnification capped at the same low general liability cap, leaving real IP risk uncovered

---

## 7. IP Ownership

### What to Check
- Who owns work product created under the agreement?
- Is the agreement a license or an assignment?
- Does the vendor retain rights in pre-existing IP ("background IP") they bring to the engagement?
- Does the customer get a license to vendor's background IP embedded in deliverables?
- Who owns improvements, feedback, and trained models derived from customer data?

### What's Standard / Fair
- **SaaS:** Customer gets a limited use license; vendor retains all IP in the platform
- **Custom development / SOW:** Customer should own custom deliverables created specifically for them; vendor retains background IP and gets a license back to use it
- Vendor background IP is clearly identified (by exhibit or general description) before work begins
- Customer retains ownership of its data at all times; vendor gets a limited license to process data to provide services
- AI/ML products: any model training on customer data produces outputs owned by customer; vendor should not retain right to use customer data to train models for other customers

### Red Flags
- All work product assigned to vendor regardless of who funded it
- No license back to vendor background IP embedded in deliverables (customer gets code they can't use)
- Vendor claims ownership of customer data or customer-generated content
- Vendor retains right to use customer data to improve products or train models without explicit consent
- "Feedback" clause: customer's suggestions and feature requests become vendor's IP free and clear — standard, but worth noting
- Broad "work-for-hire" language that assigns everything, including customer's pre-existing IP, to vendor

---

## 8. Confidentiality

### What to Check
- What information is covered as "Confidential Information"?
- Does the definition include information that should be protected (e.g., pricing, technical specs, business plans)?
- How long does the confidentiality obligation last?
- What are the standard carve-outs (publicly known, independently developed, etc.)?
- Are there obligations to notify the other party if a disclosure is required by law?

### What's Standard / Fair
- Broad definition: all non-public information disclosed in connection with the agreement, marked confidential or that a reasonable party would understand to be confidential
- Duration: term of the agreement plus 3–5 years; perpetual for trade secrets
- Standard carve-outs: (1) publicly known without breach, (2) already known by recipient, (3) independently developed, (4) received from a third party without restriction
- Legal disclosure carve-out: permitted but with notice to discloser and cooperation to seek protective order
- Standard of care: same as recipient uses for its own confidential information, but not less than reasonable care

### Red Flags
- Confidentiality obligation expires at end of term with no tail — leaves sensitive information unprotected the next day
- No confidentiality obligations on vendor for customer data (relies solely on DPA)
- Definition limited to "marked Confidential" in writing — oral disclosures or unmarked documents not covered
- No notice requirement before legal disclosure — other party loses ability to seek protection
- Extremely narrow definition that excludes key categories like pricing or technical architecture

---

## 9. Data Processing

### What to Check
- Is there a Data Processing Agreement (DPA) or Privacy Addendum in place or incorporated?
- Who is the controller vs. processor?
- What are the vendor's obligations for data security, access controls, and subprocessor management?
- What are the breach notification timelines?
- Are cross-border data transfer mechanisms addressed (for GDPR-covered data)?

### What's Standard / Fair
- DPA is a standard exhibit for any vendor handling personal data; GDPR requires it
- Breach notification within 72 hours (GDPR) or promptly / within defined period (CCPA, HIPAA)
- Vendor maintains a list of subprocessors and provides notice before adding new ones
- Data processing limited to the purposes specified in the agreement (no secondary use)
- Vendor implements appropriate technical and organizational security measures (TOMs) at minimum consistent with industry standards; SOC 2 Type II certification is a reasonable baseline
- Deletion or return of personal data within 30 days of termination

### Red Flags
- No DPA for a vendor handling any personal data of EU or California residents
- Vendor can use customer personal data for its own purposes (analytics, product improvement) without explicit consent
- No breach notification obligation, or notification timeline is "reasonable" (undefined)
- Vendor retains data indefinitely post-termination
- No subprocessor controls — vendor can engage any third party with no notice
- Standard contract clauses (SCCs) not in place for EU-to-non-EU transfers

---

## 10. Governing Law & Dispute Resolution

### What to Check
- Which state/country law governs?
- Where must disputes be litigated (venue)?
- Is there a mandatory arbitration clause? Is it binding? Does it include class action waiver?
- Is there a dispute escalation process (e.g., escalation to senior executives before litigation)?
- Are injunctive relief rights preserved?

### What's Standard / Fair
- Governing law: state where customer is headquartered, or mutual agreement on a neutral jurisdiction (Delaware is common)
- Venue: courts in the agreed governing law jurisdiction
- Optional: informal escalation (30 days of good-faith negotiation) before arbitration/litigation
- Injunctive relief preserved for IP and confidentiality breaches (cannot wait for arbitration when there's irreparable harm)
- Arbitration: binding arbitration with JAMS or AAA rules is common and acceptable; ensure it doesn't strip court access for small claims

### Red Flags
- Mandatory arbitration in a venue far from customer's operations
- Class action waiver (potentially unenforceable but worth flagging)
- No carve-out for injunctive relief — must arbitrate even in emergency IP situations
- Governing law is vendor's home jurisdiction in a state with highly vendor-favorable courts
- One-way attorneys' fees clause (vendor gets fees if it prevails; customer does not)
- Arbitration clause that requires individual-employee disputes under the MSA to be arbitrated (overbroad)
