# Apatite biosignature detection (R code)

Reproducible R workflows for:

- Binary Random Forest classification
- Cross-validation analyses
- Model interpretation
- Three-class PCA visualization

Run the full pipeline with:

```r
source("run_all.R")
```

## Data availability

The datasets used in this study are hosted on the Open Science Framework (OSF):

- OSF: https://doi.org/10.17605/OSF.IO/NJZ6C

### Expected datasets

- **Binary dataset (n = 255)**
  - Columns: 21 features + `Attribute` + `Sources`
  - Classes: Abiotic (121), Biotic (134)
  - `Sources` is required for LOSO-CV only.

- **Three-class dataset (n = 331)**
  - Columns: features + `Attribute` + `No`
  - Classes: Abiotic / Synthetic (76) / Biotic
  - `No` is used only for defining Synthetic subtypes and is excluded from the PCA feature matrix.

After downloading from OSF, place the CSV files anywhere locally and select them when prompted by the scripts.
