############################################################
# run_all.R
#
# Master entry point for the apatite biosignature project.
#
# This script orchestrates two independent workflows:
#   (A) Binary RF classification (255 dataset)
#   (B) Three-class PCA analysis (331 dataset)
#
# Each workflow is implemented in self-contained modules
# under code/.
############################################################

cat("\n========================================\n")
cat("Apatite biosignature analysis pipeline\n")
cat("========================================\n")

# ----------------------------------------------------------
# Helper: safe source
# ----------------------------------------------------------
safe_source <- function(path) {
  if (!file.exists(path)) {
    stop("Required script not found: ", path)
  }
  source(path, local = FALSE)
}

# ==========================================================
# Option selector
# ==========================================================
cat("\nSelect workflow to run:\n")
cat("  1 = Binary RF (255)\n")
cat("  2 = Three-class PCA (331)\n")
cat("  3 = BOTH (default)\n")

choice <- suppressWarnings(as.integer(readline("Enter 1/2/3: ")))
if (is.na(choice)) choice <- 3

if (!choice %in% c(1, 2, 3)) {
  stop("Invalid choice. Please enter 1, 2, or 3.")
}

# ==========================================================
# A) Binary RF pipeline
# ==========================================================
if (choice %in% c(1, 3)) {
  
  cat("\n\n==============================\n")
  cat("Running binary RF workflow\n")
  cat("==============================\n")
  
  safe_source("code/binary_rf/00_setup_binary.R")
  safe_source("code/binary_rf/01_data_binary.R")
  safe_source("code/binary_rf/02_rf_repeatedcv.R")
  safe_source("code/binary_rf/03_rf_test_eval.R")
  safe_source("code/binary_rf/04_plot_confusion_matrix.R")
  safe_source("code/binary_rf/05_plot_feature_importance.R")
  
  # optional advanced analyses
  # safe_source("code/binary_rf/06_plot_pdp_ice.R")
  # safe_source("code/binary_rf/07_cv_loocv.R")
  # safe_source("code/binary_rf/08_cv_losocv.R")
  # safe_source("code/binary_rf/09_permutation_test.R")
  
  cat("\nBinary RF workflow completed.\n")
}

# ==========================================================
# B) Three-class PCA pipeline
# ==========================================================
if (choice %in% c(2, 3)) {
  
  cat("\n\n==============================\n")
  cat("Running three-class PCA workflow\n")
  cat("==============================\n")
  
  safe_source("code/pca_threeclass/00_setup_pca3.R")
  safe_source("code/pca_threeclass/01_data_pca3.R")
  safe_source("code/pca_threeclass/02_pca_threeclass_basic.R")
  safe_source("code/pca_threeclass/03_pca_threeclass_subtypes.R")
  
  cat("\nThree-class PCA workflow completed.\n")
}

cat("\n\nAll requested workflows finished successfully.\n")