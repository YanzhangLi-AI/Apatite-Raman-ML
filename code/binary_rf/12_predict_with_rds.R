############################################################
# 12_predict_with_rds.R
# Load RF model (.rds) and predict Biotic probability for new data
#
# Input: a CSV with exactly the 21 feature columns (same names as training)
# Output: printed table + optional CSV "predictions_biotic_prob.csv"
############################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(ranger)
})

# ---- Load model artifact ----
artifact_path <- "model/rf_biotic_model.rds"
if (!file.exists(artifact_path)) stop("Model file not found: ", artifact_path)

artifact <- readRDS(artifact_path)
rf_model <- artifact$model
feature_names <- artifact$feature_names
pos_class <- artifact$pos_class

cat("Loaded model:", artifact_path, "\n")
cat("Model expects", length(feature_names), "features.\n")

# ---- Load new data (user selects) ----
new_df <- read.csv(file.choose(), stringsAsFactors = FALSE)

# Allow extra columns: keep only required features
missing_cols <- setdiff(feature_names, names(new_df))
extra_cols   <- setdiff(names(new_df), feature_names)

if (length(missing_cols) > 0) {
  stop("Your input is missing required feature columns: ",
       paste(missing_cols, collapse = ", "))
}

# Reorder columns to match training
new_x <- new_df[, feature_names, drop = FALSE]

# Make sure numeric
new_x <- as.data.frame(lapply(new_x, function(x) as.numeric(as.character(x))))

# NA check
if (anyNA(new_x)) {
  stop("Your input contains NA after numeric conversion. Please fix missing/non-numeric values.")
}

# ---- Predict probabilities ----
prob_mat <- predict(rf_model, data = new_x)$predictions
biotic_prob <- as.numeric(prob_mat[, pos_class])

# ---- Output ----
out <- data.frame(
  Row = seq_len(nrow(new_x)),
  Biotic_Probability = biotic_prob
)

print(out)

# Optional: write to CSV (uncomment if desired)
# write.csv(out, "predictions_biotic_prob.csv", row.names = FALSE)
# cat("Saved: predictions_biotic_prob.csv\n")