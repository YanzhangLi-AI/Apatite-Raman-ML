# Random Forest Model for Biotic Probability Prediction

This folder contains the trained Random Forest model used to estimate the probability that an apatite Raman spectrum is of **biotic origin**.

The model was trained on curated Raman-derived features using the workflow described in the main repository.

---

## Model file

- **rf_biotic_model.rds** — serialized ranger Random Forest model with metadata

The model expects **21 numeric input features** corresponding to the band-resolved Raman parameters used in this study.

---

## Requirements

R (>= 4.1 recommended) with packages:

- ranger
- dplyr

Install if needed:

```r
install.packages(c("ranger", "dplyr"))
```

---

## Quick start

From the repository root:

```r
source("code/binary_rf/13_predict_with_rds.R")
```

You will be prompted to select a CSV file containing the input features.

---

## Input data format

Your input CSV must contain the **same 21 feature columns** used during training:

W1 Y1 X1
W2 Y2 X2
...
W7 Y7 X7

### Requirements

- Column names must match exactly
- Values must be numeric
- No missing values (NA)
- File may contain one or many rows

### Allowed

- Extra columns (they will be ignored)
- Any row order

### Not allowed

- Missing required feature columns
- Non-numeric values in feature columns
- NA values

---

## Output

The prediction script returns a table:

| Row | Biotic_Probability |
|-----|--------------------|
| 1   | 0.932 |
| 2   | 0.127 |

Where:

- **Biotic_Probability** is the Random Forest estimated probability of biogenic origin
- Values range from **0 to 1**

---

## Interpretation

General guidance:

- > 0.8 -> high-confidence biotic
- 0.5-0.8 -> ambiguous / mixed signals
- < 0.5 -> likely abiotic

Users should interpret results in geological context.

---

## Important notes

- This model was trained only on apatite Raman-derived features.
- Predictions outside the training feature space may be unreliable.
- The model does NOT replace geological or petrographic interpretation.

---

## Reproducibility

To regenerate the model from scratch:

```r
source("code/binary_rf/12_export_model_rds.R")
```

---

## Maintainer

Yanzhang Li  
Earth and Planets Laboratory  
Carnegie Institution for Science
