# Statistical Test Selector

A reference guide for choosing the right statistical test based on question type, data structure, and assumptions. Work through the relevant section and check assumptions before running any test.

---

## Comparing Two Groups

### Parametric: Independent Samples t-test

- **Null hypothesis:** H₀: μ₁ = μ₂ (the means of the two populations are equal)
- **When to use:** Comparing means of two independent groups; outcome is continuous; sample sizes reasonably large (n ≥ 30 per group) or data are approximately normally distributed
- **Key assumptions:**
  - Independence of observations
  - Approximately normal distribution within each group (or large n by CLT)
  - Homogeneity of variance (Levene's test; if violated, use Welch's t-test — which is the default in most software)
- **If assumptions are violated:** Small n + non-normal → use Mann-Whitney U

### Non-parametric: Mann-Whitney U (Wilcoxon Rank-Sum)

- **Null hypothesis:** H₀: The distribution of outcomes is the same in both groups (more precisely: P(X > Y) = 0.5)
- **When to use:** Non-normal distribution, ordinal outcomes (e.g., Likert ratings), small samples, or heavy skew (e.g., revenue, session duration)
- **Key assumptions:** Independent observations; similar distribution shape in both groups (if testing median shift)
- **Note:** More robust but less statistical power than t-test when t-test assumptions hold

---

## Comparing 3+ Groups

### Parametric: One-Way ANOVA

- **Null hypothesis:** H₀: μ₁ = μ₂ = ... = μₖ (all group means are equal)
- **When to use:** Comparing means across 3+ independent groups; continuous outcome; data approximately normal
- **Key assumptions:** Independence, normality within groups, homogeneity of variance (use Levene's test; if violated, use Welch's ANOVA)
- **Important:** ANOVA only tells you *that* a difference exists, not *where*. Run post-hoc tests (Tukey's HSD for equal n; Games-Howell if variances differ) to identify which groups differ
- **If assumptions are violated:** Use Kruskal-Wallis

### Non-parametric: Kruskal-Wallis Test

- **Null hypothesis:** H₀: All groups have the same distribution (medians equal under symmetry assumption)
- **When to use:** Non-normal data, ordinal outcomes, 3+ independent groups
- **Key assumptions:** Independent observations; similar distribution shape across groups
- **Post-hoc:** Dunn's test with Bonferroni or FDR correction for pairwise comparisons

---

## Comparing Proportions / Categorical Outcomes

### Chi-Square Test of Independence

- **Null hypothesis:** H₀: The two categorical variables are independent (no association)
- **When to use:** Two categorical variables; large sample sizes; expected cell counts ≥ 5 in all cells
- **Key assumptions:** Independent observations; expected frequency ≥ 5 per cell (rule of thumb)
- **If assumptions are violated:** Use Fisher's Exact Test

### Fisher's Exact Test

- **Null hypothesis:** H₀: The odds ratio equals 1 (no association between the two categorical variables)
- **When to use:** Small samples where expected cell counts < 5; 2×2 contingency tables; exact p-values needed (e.g., rare events)
- **Key assumptions:** Fixed marginal totals (hypergeometric distribution)
- **Note:** Fisher's is always valid for 2×2 tables regardless of sample size; chi-square is an approximation that works well with large samples

---

## Correlation

### Pearson Correlation (r)

- **Null hypothesis:** H₀: ρ = 0 (no linear relationship between the two variables)
- **When to use:** Both variables are continuous; relationship is expected to be linear; data are approximately bivariate normal
- **Key assumptions:** Linear relationship (check scatter plot); no severe outliers; interval or ratio scale
- **Interpretation:** r measures the strength and direction of a *linear* relationship; r² (coefficient of determination) gives the proportion of variance explained
- **If assumptions are violated:** Use Spearman

### Spearman Rank Correlation (ρ)

- **Null hypothesis:** H₀: ρ = 0 (no monotonic relationship)
- **When to use:** Ordinal data; non-linear but monotonic relationships; data with outliers or non-normal distributions
- **Key assumptions:** Monotonic relationship (always check a scatter plot); ordinal or continuous data
- **Note:** Works by ranking both variables first, then applying Pearson to the ranks

---

## Regression

### Linear Regression

- **When to use:** Continuous outcome variable; predicting or explaining the magnitude of an outcome; quantifying the relationship between predictors and outcome
- **Key assumptions:** Linearity, independence of errors, homoscedasticity (constant error variance), normality of residuals, no severe multicollinearity among predictors
- **Check assumptions via:** Residual plots (residuals vs. fitted, Q-Q plot of residuals)
- **If assumptions are violated:** Transform outcome (log, sqrt), add polynomial terms, use robust regression, or switch to a generalized linear model
- **Output interpretation:** Coefficients represent the change in the outcome for a one-unit change in the predictor, holding others constant

### Logistic Regression

- **When to use:** Binary outcome (yes/no, converted/not, churned/not); predicting the probability of an event
- **Key assumptions:** Independence of observations; no severe multicollinearity; large sample relative to number of predictors (rule of thumb: ≥ 10 events per predictor); linear relationship between log-odds and continuous predictors
- **Output interpretation:** Coefficients are in log-odds; exponentiate to get odds ratios. For binary outcomes, odds ratio > 1 means the predictor increases odds of the event
- **Extensions:** Multinomial logistic regression for 3+ unordered categories; ordinal logistic regression for ordered categories

---

## Time Series

### Key Concepts Before Testing

**Stationarity:** A stationary time series has constant mean, variance, and autocorrelation structure over time. Most classical time series models assume stationarity.
- Test for stationarity: Augmented Dickey-Fuller (ADF) test — H₀ is that a unit root exists (series is non-stationary). Rejecting H₀ supports stationarity.
- If non-stationary: Apply differencing (subtract previous period) until stationary; log-transform for multiplicative seasonality.

**Autocorrelation:** The correlation of a series with its own lagged values. Present in most real-world time series (e.g., sales today is correlated with sales yesterday).
- Detect via: ACF (Autocorrelation Function) and PACF (Partial ACF) plots — spikes at specific lags indicate seasonal patterns or AR/MA components.
- Ignoring autocorrelation in regression leads to underestimated standard errors and inflated significance.

**Common Time Series Tests:**

| Test | Purpose | H₀ |
|---|---|---|
| Augmented Dickey-Fuller | Unit root (non-stationarity) | Series has a unit root (non-stationary) |
| Ljung-Box | Residual autocorrelation | No autocorrelation in residuals up to lag k |
| Granger Causality | Whether one series predicts another | X does not Granger-cause Y |

---

## Assumption Violation Quick Reference

| Violation | Parametric Default | Non-Parametric Alternative |
|---|---|---|
| Non-normal, small n, comparing 2 groups | t-test | Mann-Whitney U |
| Non-normal, comparing 3+ groups | ANOVA | Kruskal-Wallis |
| Small expected cell counts (< 5) | Chi-square | Fisher's Exact |
| Outliers / non-linear monotonic relationship | Pearson r | Spearman ρ |
| Non-constant error variance in regression | OLS regression | Robust standard errors (HC3) or WLS |
