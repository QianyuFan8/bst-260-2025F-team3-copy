---
editor_options: 
  markdown: 
    wrap: 72
---

# Risk Factors for Diabetes Among Adults Aged 40+: A Combined Logistic Regression and Random Forest Analysis Using NHANES Data

## Project Overview

This project examines socioeconomic, behavioral, and psychosocial
determinants of diabetes among U.S. adults aged 40 years and older using
data from the National Health and Nutrition Examination Survey (NHANES).
We employ complementary analytical approaches—multivariable logistic
regression and Random Forest modeling—to identify robust diabetes risk
factors and compare variable importance rankings across parametric and
non-parametric frameworks.

**Research Questions:** 1. Among U.S. adults aged 40 years and older,
how do socioeconomic, behavioral, and psychosocial factors influence the
risk of diabetes? 2. How do the variable importance rankings from a
Random Forest model compare with the statistically significant
predictors from logistic regression?

------------------------------------------------------------------------

## Repository Structure

```         
.
├── code/
│   ├── data_wrangling.R        # Data cleaning, preprocessing, and imputation
│   ├── logistic_reg.R          # Logistic regression modeling
│   └── random_forest.R         # Random Forest modeling
├── data/
│   ├── ourdata.rds             # Raw data after initial filtering (age ≥40)
│   ├── dat_imputed.rds         # Data after KNN imputation
│   └── clean_data.rds          # Final cleaned dataset for modeling
├── docs/
│   ├── final-project.pdf           # Rendered PDF report
│   ├── Supplementary_Methods.pdf   # Rendered supplementary materials
│   ├── Sylvia Deng.txt             # Sylvia Deng's contributions and effort
│   ├── Yinuo Du.txt                # Yinuo Du's contributions and effort
│   └── Qianyu Fan.txt              # Qianyu Fan's contributions and effort
├── final-project.qmd           # Main analysis report (Quarto Markdown)
├── Supplementary_Methods.qmd   # Supplementary methods and figures
├── header.tex                  # LaTeX header for PDF formatting
├── Outline.txt                 # Project outline and planning notes
└── README.md                   # This file
```

------------------------------------------------------------------------

## Prerequisites

### Software Requirements

-   **R version**: 4.3.0 or higher
-   **RStudio**: Recommended for running .qmd files
-   **Quarto**: Required for rendering .qmd to PDF (install from
    <https://quarto.org>)

### R Packages

Install all required packages by running:

``` r
# Install CRAN packages
install.packages(c(
  "NHANES",       # NHANES data
  "tidyverse",    # Data manipulation and visualization
  "broom",        # Tidy model outputs
  "car",          # VIF calculation
  "VIM",          # KNN imputation
  "reshape2",     # Data reshaping
  "patchwork",    # Combine plots
  "ggcorrplot",   # Correlation plots
  "RColorBrewer", # Color palettes
  "here",         # File path management
  "DescTools",    # Descriptive statistics
  "knitr",        # Report generation
  "kableExtra",   # Table formatting
  "randomForest", # Random Forest modeling
  "caret",        # Machine learning framework
  "pROC",         # ROC curve analysis
  "PRROC",        # Precision-Recall curves
  "vip"           # Variable importance plots
))
```

------------------------------------------------------------------------

## Reproducing the Analysis

### Step 1: Clone the Repository

``` bash
git clone https://github.com/your-username/diabetes-risk-nhanes.git
cd diabetes-risk-nhanes
```

### Step 2: Run Data Processing Scripts

Execute the scripts in the following order:

#### 2.1 Data Wrangling

``` r
# Run data cleaning and preprocessing
source("code/data_wrangling.R")
```

This script performs: - Loads NHANES data and filters to adults aged
≥40 - Removes duplicate observations and pregnant women - Corrects data
quality issues (outliers, inconsistencies) - Performs KNN imputation
(k=5) for missing data - Selects variables and creates derived variables
(e.g., smoking status, alcohol categories) - Saves intermediate
datasets: `ourdata.rds`, `dat_imputed.rds`, `clean_data.rds`

**Key outputs:** - `data/ourdata.rds`: n=2,873 adults aged ≥40 -
`data/dat_imputed.rds`: Data after KNN imputation -
`data/clean_data.rds`: Final dataset with all transformations applied

#### 2.2 Logistic Regression

``` r
# Run logistic regression analysis
source("code/logistic_reg.R")
```

This script performs: - Fits multivariable logistic regression with 17
predictors - Computes variance inflation factors (VIF) - Generates
diagnostic plots - Exports model results and coefficients

**Key outputs:** - Logistic regression model object (`mod`) - Table of
odds ratios and 95% confidence intervals - Variable importance rankings
(by \|z-value\|)

#### 2.3 Random Forest

``` r
# Run Random Forest analysis
source("code/random_forest.R")
```

This script performs: - Trains Random Forest classifier with 5-fold
cross-validation - Addresses class imbalance via downsampling - Tunes
`mtry` hyperparameter - Evaluates model performance (ROC-AUC,
sensitivity, specificity and balanced accuracy) - Computes variable
importance (permutation-based)

**Key outputs:** - Random Forest model object (`rf_balanced`) - ROC
curve - Variable importance rankings - Confusion matrix

------------------------------------------------------------------------

### Step 3: Render the Final Report

#### 3.1 Main Report

``` bash
# In terminal/command line
quarto render final-project.qmd
```

Or in RStudio: 1. Open `final-project.qmd` 2. Click "Render" button (or
press Ctrl/Cmd + Shift + K)

This generates `final-project.pdf` containing: - Abstract -
Introduction - Methods - Results (including tables and figures) -
Discussion - References

#### 3.2 Supplementary Materials

``` bash
quarto render Supplementary_Methods.qmd
```

This generates `Supplementary_Methods.pdf` containing: - Supplementary
Table S1: Variable definitions - Supplementary Table S2: Missing data
summary - Supplementary Table S3: VIF values - Supplementary Table S4:
Smoking characteristics by diabetes status - Supplementary Figure S1:
Correlation matrices - Supplementary Figure S2: Logistic regression
diagnostic plots

------------------------------------------------------------------------

## Key Findings

### Main Results

1.  **Demographic factors**: Age (OR=1.04, p\<0.001) and race/ethnicity
    showed strong associations, with Black participants exhibiting
    higher diabetes odds than White, Asian, and Hispanic participants.

2.  **Socioeconomic factors**: Low income (OR=1.49, p=0.034) and home
    rental (OR=1.41, p=0.011) independently predicted higher diabetes
    odds.

3.  **Behavioral factors**: Short sleep duration (OR=1.26, p=0.037),
    sleep trouble (OR=1.36, p=0.009), and computer use (OR=1.13 per
    hour, p=0.010) were associated with increased diabetes risk.

4.  **Psychosocial factors**: Depression showed a significant positive
    association (OR=1.43, p=0.016).

5.  **Paradoxical findings**: Current smoking showed an inverse
    association (OR=0.74, p=0.046), likely reflecting survival bias and
    reverse causation in cross-sectional data.

### Model Comparison

-   **High concordance**: 5 of top 10 variables overlapped between
    logistic regression and Random Forest (age, race, poverty, gender,
    computer use)
-   **Divergence**: Marital status and smoking ranked higher in Random
    Forest, suggesting potential nonlinear relationships
-   **Conclusion**: Both parametric and non-parametric approaches
    converged on similar risk factors, strengthening confidence in
    findings

------------------------------------------------------------------------

## Data Processing Details

### Variable Transformations

| Original Variable | Transformation | Rationale |
|------------------------------|------------------------|------------------|
| `Poverty` (IPR) | 3 categories: Low (≤1.0), Middle (1.0-4.0), High (≥4.0) | Nonlinear association (Liu et al., 2023) |
| `SleepHrsNight` | 3 categories: Short (\<7), Adequate (7-9), Long (\>9) | U-shaped relationship (Cappuccio et al., 2010) |
| `SmokeNow` + `Smoke100` | 3 categories: Never, Former, Current | Standard smoking classification |
| `AlcoholDay` × `AlcoholYear` | 3 categories: Non-drinker, Light-Moderate (\<730/yr), Heavy (≥730/yr) | Annual consumption |
| `TVHrsDay`, `CompHrsDay` | Ordinal → Numeric (midpoints) | Continuous approximation |
| `LittleInterest`, `Depressed` | Binary (any frequency = "Yes") | PHQ-2 depression screening |

### Missing Data Handling

**KNN Imputation (k=5)** was applied to variables with the following
missingness rates:

| Variable         | Missing (%) | Pattern                    |
|------------------|-------------|----------------------------|
| `SmokeNow`       | 52.5        | Likely informative         |
| `SmokeAge`       | \>50        | Likely informative         |
| `PhysActiveDays` | 54.7        | Likely informative         |
| `AlcoholDay`     | 38.1        | Likely informative         |
| `AlcoholYear`    | 20.0        | Likely informative         |
| `CompHrsDay`     | 50.0        | Structural (2009-10 cycle) |

**Limitations**: KNN assumes missing-at-random (MAR), which may be
violated for substance use variables. Complete absence of computer use
data in 2009-2010 introduces potential temporal bias.

------------------------------------------------------------------------

## Model Specifications

### Logistic Regression

```         
logit(P(Diabetes=Yes)) = β₀ + Σ(βⱼXⱼ)
```

-   **Predictors**: 17 variables (29 terms including dummy variables)
-   **Reference categories**: Female, Black, ≤High School, Never
    Married, High Income, Working, Own, Adequate Sleep (7-9 hrs), Never
    Smoker, Light-Moderate Drinker, No Depression
-   **Diagnostics**: VIF \< 5, diagnostic plots

### Random Forest

-   **Trees**: 500
-   **mtry**: Tuned via 5-fold CV (optimal value selected by ROC-AUC)
-   **Class imbalance**: Downsampling during training
-   **Performance metrics**: ROC-AUC = 0.719, Sensitivity = 0.73,
    Specificity = 0.627
-   **Variable importance**:permutation-based (AUC degradation)

------------------------------------------------------------------------

## Limitations

1.  **Cross-sectional design**: Cannot establish causality; vulnerable
    to reverse causation
2.  **Missing data**: Extensive missingness (\>50% for some variables);
    MAR assumption may be violated
3.  **Self-reported measures**: Recall bias and social desirability bias
4.  **Temporal bias**: Computer use data completely absent in 2009-2010
5.  **Unmeasured confounding**: Diet quality, genetic factors,
    healthcare access not available

------------------------------------------------------------------------

## References

**Key papers cited in analysis:**

-   Centers for Disease Control and Prevention. (2024). National
    Diabetes Statistics Report.
    <https://www.cdc.gov/diabetes/data/statistics-report/index.html>

-   Cappuccio, F. P., et al. (2010). Quantity and quality of sleep and
    incidence of type 2 diabetes: A systematic review and meta-analysis.
    *Diabetes Care*, 33(2), 414-420. <https://doi.org/10.2337/dc09-1124>

-   Hill-Briggs, F., et al. (2021). Social determinants of health and
    diabetes: A scientific review. *Diabetes Care*, 44(1), 258-279.
    <https://doi.org/10.2337/dci20-0053>

-   Liu, C., et al. (2023). Diabetes risk among US adults with different
    socioeconomic status and behavioral lifestyles. *Frontiers in Public
    Health*, 11, 1197947.

-   Menke, A., et al. (2015). Prevalence of and trends in diabetes among
    adults in the United States, 1988-2012. *JAMA*, 314(10), 1021-1029.
    <https://doi.org/10.1001/jama.2015.10029>

**Full reference list available in**: `final-project.pdf`

------------------------------------------------------------------------

## Acknowledgments

-   **Data source**: National Health and Nutrition Examination Survey
    (NHANES), Centers for Disease Control and Prevention
-   **R packages**: Special thanks to the developers of NHANES,
    tidyverse, randomForest, caret, pROC, VIM, and all other packages
    used in this analysis
-   **Course**: BST 260 Introduction to Data Science; Instructors:
    Robert Gentleman, Anthony Christidis; Teaching fellows: Angela Wang,
    Ava Harrington, Emma Crenshaw, Jing Li
