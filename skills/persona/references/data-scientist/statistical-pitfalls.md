# Statistical Pitfalls Reference

Common statistical pitfalls encountered in data science and research, with detection heuristics and remedies. Knowing a pitfall exists is not enough — use the detection heuristics to actively check for it in your own work.

---

## 1. P-Hacking

**Definition:** The practice (conscious or not) of running analyses, transformations, or subgroup cuts until a p-value below 0.05 is found, then reporting only that result as if it were the pre-specified analysis. Also called "data dredging."

**How it happens:**
- Testing multiple outcomes and reporting only the significant one
- Stopping data collection as soon as significance is reached
- Trying different covariate combinations, transformations, or exclusion criteria until p < 0.05
- Running subgroup analyses and highlighting whichever subgroup shows the effect

**Detection heuristics (in your own analysis):**
- Ask: "Did I decide what to test before looking at the data, or did I discover this 'hypothesis' by exploring the data?"
- Count the number of tests you ran — if you ran 20 and found 1 significant result, that result is exactly what you'd expect by chance
- Be suspicious if your result is just barely below p = 0.05 after several analytical iterations
- Check if removing or changing a single analysis decision (e.g., an exclusion filter) flips significance

**Solutions:**
- **Pre-registration:** Document your hypothesis, primary metric, analysis plan, and sample size *before* data collection. Platforms: OSF (Open Science Framework), AsPredicted.org. Pre-registration creates a public, time-stamped record that separates confirmatory analysis from exploratory analysis.
- Explicitly label exploratory analyses as exploratory — they generate hypotheses, not conclusions
- Apply multiple comparison corrections when testing multiple outcomes (see Section 7)
- Report all tests run, not just significant ones

---

## 2. Simpson's Paradox

**Definition:** A trend appears in subgroups of data but disappears or reverses when the groups are combined, because a confounding variable is unevenly distributed across the groups being combined.

**Worked Example — UC Berkeley Admissions (1973):**
Aggregate data showed men had a higher admission rate than women (~44% vs. ~35%), suggesting gender bias. But when broken down by department, women had equal or higher admission rates in almost every department. The paradox arose because women applied disproportionately to competitive departments (low acceptance rates), while men applied to less competitive departments (high acceptance rates). The aggregate masked the subgroup reality.

| | Men Admitted | Women Admitted |
|---|---|---|
| Dept A (hard, ~10% rate) | 10 of 120 = **8.3%** | 20 of 200 = **10%** ← women higher |
| Dept B (easy, ~55% rate) | 200 of 380 = **52.6%** | 50 of 80 = **62.5%** ← women higher |
| **Overall** | **210 of 500 = 42%** | **70 of 280 = 25%** ← men appear higher |

(Simplified illustration.) Women are admitted at a higher rate in *both* individual departments. But in aggregate, men appear much better — because men disproportionately applied to the easier department (76% of men applied to Dept B vs. 29% of women). The confounding variable (which department was applied to) reverses the apparent direction at the aggregate level.

**How to detect:**
- Always check subgroups when reporting aggregate statistics — especially when comparing groups that differ in composition (age, experience level, customer segment, device type)
- If aggregate and subgroup trends disagree, a confounding variable is lurking
- Check whether the groups being compared differ on a variable that also affects the outcome

**Solution:**
Stratify the analysis by the confounding variable. Report subgroup results. Use regression to control for the confounder if you want a single adjusted estimate.

---

## 3. Data Leakage

**Definition:** Information from outside the training dataset (or future information) that is inappropriately used to build or evaluate a model, causing the model to appear more accurate than it actually is on new data.

**Common sources in ML pipelines:**
- **Feature leakage:** A feature that would not be available at prediction time is included in training (e.g., using the timestamp of a fraud flag as a feature when predicting fraud)
- **Target leakage:** A feature is causally downstream of the target (e.g., using "received a collection call" to predict default — by the time you make the call, the default is already happening)
- **Preprocessing leakage:** Normalization, scaling, or imputation is fit on the full dataset (including the test set) before splitting — the test set indirectly influences the preprocessing parameters
- **Temporal leakage:** In time series, the model is trained on future data relative to what it is predicting (e.g., predicting January sales using features computed from February data)
- **Group leakage:** The same user, patient, or entity appears in both train and test sets, inflating generalization metrics

**How to detect:**
- Suspiciously high accuracy on held-out data (especially accuracy that far exceeds domain baselines) is a red flag
- Examine feature importances — if a feature has implausibly high importance and a causal explanation is unclear, investigate whether it leaks the target
- Check the temporal relationship between features and the target: every feature must be available at the time of prediction
- Verify that your train/test split was done before any preprocessing (or that preprocessing is fit only on training data)

**Solution:**
- Implement preprocessing in a pipeline that is fit only on training data and applied to test data
- In time series, always use a temporal split (train on past, evaluate on future)
- When the same entity can appear multiple times, use group-based cross-validation

---

## 4. Selection Bias

**Definition:** The sample used for analysis is not representative of the population of interest because the selection process is correlated with the outcome being studied.

### Types

**Survivorship Bias:** Only "survivors" of some process are observed. Classic example: analyzing why successful startups succeeded using only successful startups — failed startups aren't in the dataset. In A/B testing: analyzing only users who completed a flow introduces survivorship bias if the variants differentially affect drop-off.

**Non-Response Bias:** People who respond to a survey differ systematically from those who don't. Satisfied users are less likely to respond to support surveys; disengaged users don't open email surveys. The result systematically misrepresents the full population.

**Sampling Bias:** The method of sample collection excludes certain segments. Online surveys exclude non-internet users; usability studies run on weekdays during business hours exclude working parents and shift workers.

**Detection heuristics:**
- Ask: "Who is missing from my dataset, and why?" The missing people are often the most informative
- Compare respondents to non-respondents on observable characteristics when possible
- In A/B tests: if analyzing a subset of assigned users (e.g., "users who completed step 1"), check whether the variants differ in who makes it to that subset
- For observational data: check whether the studied population matches the target population on key demographics

**Solutions:**
- Weight responses to match population distributions when demographics are known
- Analyze on intent-to-treat populations (all assigned users), not completers
- Report limitations of sample representativeness explicitly

---

## 5. Overfitting

**Definition:** A model learns the noise and idiosyncrasies of the training data rather than generalizable patterns, resulting in excellent training performance but poor performance on new data.

**Symptoms:**
- Large gap between training accuracy and validation/test accuracy
- Model performance degrades significantly on data from a different time period or user segment
- Very complex model (many parameters, deep trees) with a small dataset
- Adding features consistently improves training metrics but does not improve held-out metrics

**Train / Validation / Test Discipline:**
- **Training set:** Used to fit model parameters
- **Validation set:** Used to tune hyperparameters and select model architecture — cannot be used to evaluate final performance
- **Test set:** Used exactly once to report final model performance — touching it during development invalidates it as an unbiased estimator

Violating this discipline (e.g., tuning hyperparameters based on test set performance) causes the test set to effectively become a second validation set, and reported performance is optimistic.

**Cross-Validation:**
When data is limited, k-fold cross-validation (typically k = 5 or 10) uses all data for both training and validation in rotation, providing a more reliable estimate of generalization error than a single split. For time series data, use time-series cross-validation (expanding window or sliding window) to respect temporal ordering.

**Remedies:**
- Regularization (L1/L2) to penalize model complexity
- Early stopping in iterative models (gradient boosting, neural networks)
- Reduce model complexity (fewer features, shallower trees)
- Collect more data

---

## 6. Confounding

**Definition:** A confounding variable (confounder) is associated with both the treatment/predictor and the outcome, creating a spurious association between them that is not causal.

**Example:** Ice cream sales and drowning rates are positively correlated. The confounder is temperature/season — hot weather causes both more ice cream consumption and more swimming (hence more drowning). Ice cream does not cause drowning.

**In observational data, confounding is ubiquitous.** People who exercise are also more likely to eat well, sleep more, have higher income, and have access to healthcare — all of which affect health outcomes independently of exercise.

**How to detect:**
- Ask: "Is there a common cause of both my independent variable and my dependent variable?"
- Draw a DAG (Directed Acyclic Graph) of assumed causal relationships to identify potential backdoor paths
- Check whether the association weakens or disappears when you condition on the suspected confounder
- Be especially suspicious of correlations that have no plausible causal mechanism

**When to use causal inference methods:**
When the research question is explicitly causal ("does X cause Y?") and randomization is not possible, use:
- **Regression with controls:** Adjusts for measured confounders; cannot address unmeasured ones
- **Instrumental Variables (IV):** Uses an instrument (variable that affects treatment but not outcome except through treatment) to isolate exogenous variation
- **Difference-in-Differences (DiD):** Compares before/after changes in treatment vs. control groups; requires parallel trends assumption
- **Propensity Score Matching:** Matches treated and control units on probability of receiving treatment to reduce observed confounding

Note: No observational method fully eliminates confounding from unmeasured variables. Always state this limitation.

---

## 7. Multiple Comparisons

**Definition:** When many hypothesis tests are run simultaneously, the probability of at least one false positive increases substantially, even if all null hypotheses are true.

**The core problem:** At α = 0.05, if you run 20 independent tests, the probability of at least one false positive is 1 − (0.95)²⁰ ≈ 64%. In a typical experiment with 20 tracked metrics, expecting one "significant" result is entirely consistent with the null being true for all of them.

**Corrections:**

### Bonferroni Correction

Adjust the significance threshold to α / m, where m is the number of tests.

Example: 10 tests, α = 0.05 → use α* = 0.005 per test. Only reject H₀ if p < 0.005.

- **Pro:** Simple; controls Family-Wise Error Rate (FWER) — the probability of any false positive
- **Con:** Conservative; low power when m is large; assumes independence of tests

### False Discovery Rate (FDR) — Benjamini-Hochberg Procedure

Controls the *expected proportion* of significant results that are false positives (rather than controlling the probability of any false positive). Less conservative than Bonferroni; better for exploratory research with many comparisons.

**Procedure:**
1. Rank p-values from smallest to largest: p₁ ≤ p₂ ≤ ... ≤ pₘ
2. Find the largest k such that pₖ ≤ (k/m) × q, where q is the desired FDR level (commonly 0.05 or 0.10)
3. Reject all H₀ for tests 1 through k

### When Corrections Are Necessary

| Situation | Recommendation |
|---|---|
| One pre-specified primary metric | No correction needed |
| Multiple secondary metrics in an A/B test | Apply Bonferroni or report with FDR; be explicit about exploratory status |
| Subgroup analyses (post-hoc) | Always treat as exploratory; apply corrections or treat as hypothesis-generating |
| Multiple A/B test variants vs. control | Apply correction for each pairwise comparison |
| Large-scale feature scanning or ML feature selection | FDR is preferred; Bonferroni is too conservative |

**Best practice:** Pre-register exactly one primary metric. Everything else is secondary and should be labeled as such, with appropriate corrections or caveats.
