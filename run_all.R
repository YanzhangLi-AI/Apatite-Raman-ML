############################################################
# run_all.R
# Master entry for two independent workflows:
#  (1) Binary RF (Abiotic vs Biotic; 255 dataset; Sources optional)
#  (2) Three-class PCA (Abiotic / Synthetic / Biotic; 331 dataset; No required)
############################################################

cat("\n========================================\n")
cat("Apatite Raman ML workflows\n")
cat("========================================\n")

safe_source <- function(path) {
  if (!file.exists(path)) stop("Missing script: ", path)
  source(path, local = FALSE)
}

cat("\nSelect workflow to run:\n")
cat("  1 = Binary RF (255)\n")
cat("  2 = Three-class PCA (331)\n")
cat("  3 = BOTH (default)\n")

choice <- suppressWarnings(as.integer(readline("Enter 1/2/3: ")))
if (is.na(choice)) choice <- 3
if (!choice %in% c(1, 2, 3)) stop("Invalid choice. Please enter 1, 2, or 3.")

# -------------------------
# (1) Binary RF
# -------------------------
if (choice %in% c(1, 3)) {
  cat("\n\n==============================\n")
  cat("Running: Binary RF workflow\n")
  cat("==============================\n")
  
  safe_source("code/binary_rf/00_setup_binary.R")
  safe_source("code/binary_rf/01_data_binary.R")
  safe_source("code/binary_rf/02_rf_repeatedcv.R")
  safe_source("code/binary_rf/03_rf_test_eval.R")
  safe_source("code/binary_rf/04_plot_confusion_matrix.R")
  safe_source("code/binary_rf/05_plot_feature_importance.R")
  
  # Optional scripts (uncomment when needed)
  # safe_source("code/binary_rf/06_plot_pdp_ice.R")
  # safe_source("code/binary_rf/07_cv_loocv.R")
  # safe_source("code/binary_rf/08_cv_losocv.R")
  # safe_source("code/binary_rf/09_permutation_test.R")
  
  cat("\nBinary RF workflow completed.\n")
}

# -------------------------
# (2) Three-class PCA
# -------------------------
if (choice %in% c(2, 3)) {
  cat("\n\n==============================\n")
  cat("Running: Three-class PCA workflow\n")
  cat("==============================\n")
  
  safe_source("code/pca_threeclass/00_setup_pca3.R")
  safe_source("code/pca_threeclass/01_data_pca3.R")
  safe_source("code/pca_threeclass/02_pca_threeclass_basic.R")
  safe_source("code/pca_threeclass/03_pca_threeclass_subtypes.R")
  
  cat("\nThree-class PCA workflow completed.\n")
}

cat("\nAll requested workflows finished.\n")