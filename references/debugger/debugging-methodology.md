# Systematic Debugging Methodology — Reference

Debugging is hypothesis-driven investigation. Skipping steps leads to symptom fixes that leave the root cause intact. Follow this process.

---

## The 5-Step Process

```
Reproduce → Hypothesize → Test → Isolate → Verify
```

---

### Step 1: Reproduce

**Goal:** Establish a reliable, observable failure before touching any code.

**Tactics:**
- Run the reported steps in a clean environment before changing anything. This confirms the bug is real and not already fixed.
- Note every variable: OS, runtime version, input data, timing, environment config, concurrent activity.
- Determine the reproduction rate. A bug that fails 1-in-100 times requires a different strategy than one that fails every time.
- Capture exact error messages, stack traces, and logs at the moment of failure — not reconstructions from memory.

**Writing a Minimal Reproducible Case (MRC):**
1. Start from the full failing scenario.
2. Remove one component, dependency, or input dimension at a time.
3. After each removal, confirm the bug still occurs.
4. Stop when removing anything further makes the bug disappear.
5. The result is your MRC: the smallest possible program or configuration that exhibits the failure.

A good MRC is worth more than hours of inspection. It removes noise, exposes the core interaction, and makes the bug portable enough to share or bisect.

---

### Step 2: Hypothesize

**Goal:** Generate a ranked list of candidate root causes before touching anything.

**Tactics:**
- Write hypotheses as falsifiable statements: "The bug occurs because X causes Y under condition Z."
- Draw on: recent changes, the area of code the stack trace points to, known weak spots, and analogous bugs you've seen before.
- Avoid combining multiple hypotheses into one untested change. You'll lose the ability to attribute the fix.

**Ranking Hypotheses:**

Rank by two axes:

| Axis | Question to Ask |
|---|---|
| **Probability** | How likely is this cause given what I observed? Does the symptom fit exactly, or only loosely? |
| **Testability** | How quickly can I confirm or rule this out? Can I add a log line, flip a config, or write a 5-line test? |

Prioritize hypotheses that are **high probability AND fast to test**. A moderately likely hypothesis that takes 5 minutes to rule out beats a highly likely one that requires a 2-hour refactor to test.

---

### Step 3: Test

**Goal:** Design experiments that produce binary outcomes — hypothesis confirmed or falsified.

**Tactics:**
- Change only one variable per test. Two simultaneous changes make it impossible to know which one mattered.
- Make the test observable: add logging, assertions, or metric counters before running. A test you can't measure is not a test.
- Predict the outcome before you run: "If hypothesis A is correct, I expect to see log line X and counter Y to increment." Checking predictions keeps you honest.
- When a hypothesis is falsified, mark it off and move to the next — don't try to save it with ad-hoc amendments.

---

### Step 4: Isolate

**Goal:** Narrow the fault to the smallest unit of code, data, or infrastructure responsible.

**Binary Search Strategies:**
- **For code history:** Use `git bisect` to find the exact commit that introduced the bug. Mark the last-known-good and first-known-bad commits; bisect does the rest in O(log n) steps.
- **For input data:** Split the failing dataset in half. Test each half. The half that still fails is your new working set. Repeat until you have the minimal failing input.
- **For call stacks:** Comment out or stub the lower half of the call chain and test the upper half in isolation. Move the boundary toward the failure point until the bug stops crossing the stub.
- **For distributed systems:** Introduce checkpoints (log the full state before and after each service hop) and find the first hop where the data is wrong.

**Differential Debugging — What Changed Between Working and Broken?**

This is often the fastest path to a root cause. When you have a working baseline to compare against, enumerate differences:

1. **Code changes:** `git diff <working-tag>..HEAD` — focus on changes in the area the stack trace implicates.
2. **Dependency versions:** Compare lockfiles. A transitive dependency bump is a common silent culprit.
3. **Configuration and environment:** Compare env vars, feature flags, infrastructure configs (instance type, OS version, memory limits).
4. **Data shape:** Has the schema or input format changed? Does the bug only affect records created after a certain date?
5. **Load and concurrency:** Did traffic volume, concurrency level, or scheduling change around the time the bug appeared?

If you can identify what changed, you can often form a high-probability hypothesis immediately.

---

### Step 5: Verify

**Goal:** Confirm the fix addresses the root cause — not just the symptom.

**Symptom Fix vs. Root Cause Fix:**

| Type | Description | Risk |
|---|---|---|
| **Symptom Fix** | Suppresses the visible failure without addressing why it occurs (e.g., catching an exception and returning a default) | Bug persists internally; may resurface in a different form or cause data corruption silently |
| **Root Cause Fix** | Addresses the underlying incorrect logic, state, or assumption | Requires understanding the full causal chain; may touch more code |

To distinguish them: ask "If I remove this fix, does the system fail in the same way, or in a different way?" If different, you may have addressed a symptom. Follow the new failure upstream.

**Verification Checklist:**
- [ ] The MRC no longer reproduces the failure.
- [ ] Existing tests pass.
- [ ] A new regression test covers the exact scenario that failed.
- [ ] Related code paths that share the root cause have been audited.
- [ ] The fix has been explained in terms of root cause, not just symptom: "This failed because X; the fix ensures Y is always true."
