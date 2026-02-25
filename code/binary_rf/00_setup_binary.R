############################################################
# 00_setup_binary.R
# Binary RF workflow: packages, constants, utilities
############################################################

required_pkgs <- c("tidyverse", "caret", "ranger", "pROC", "ggplot2", "iml")

to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install)

suppressPackageStartupMessages({
  library(tidyverse)
  library(caret)
  library(ranger)
  library(pROC)
  library(ggplot2)
  library(iml)
})

# ---- constants ----
SEED_GLOBAL <- 666
SEED_SPLIT  <- 666
SEED_TRAIN  <- 66

POS_CLASS <- "Biotic"
NEG_CLASS <- "Abiotic"
CLASS_LEVELS <- c(NEG_CLASS, POS_CLASS)

N_TREES <- 500

set.seed(SEED_GLOBAL)

# ---- helpers ----
assert_required_cols <- function(df, cols) {
  miss <- setdiff(cols, colnames(df))
  if (length(miss) > 0) stop("Missing columns: ", paste(miss, collapse = ", "))
}

drop_sources_for_ml <- function(df) {
  df %>% dplyr::select(-any_of("Sources"))
}

make_train_test_split <- function(df, p_train = 0.75, seed = SEED_SPLIT) {
  set.seed(seed)
  idx <- caret::createDataPartition(df$Attribute, p = p_train, list = FALSE)
  list(train = df[idx, , drop = FALSE], test = df[-idx, , drop = FALSE])
}

mcc <- function(pred, obs) {
  pred <- factor(pred, levels = CLASS_LEVELS)
  obs  <- factor(obs,  levels = CLASS_LEVELS)
  
  cm <- table(pred, obs)
  cm2 <- matrix(0, 2, 2, dimnames = list(CLASS_LEVELS, CLASS_LEVELS))
  cm2[rownames(cm), colnames(cm)] <- cm
  cm <- cm2
  
  TP <- cm[POS_CLASS, POS_CLASS]
  TN <- cm[NEG_CLASS, NEG_CLASS]
  FP <- cm[POS_CLASS, NEG_CLASS]
  FN <- cm[NEG_CLASS, POS_CLASS]
  
  num <- TP * TN - FP * FN
  den <- sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN))
  if (den == 0) return(NA_real_)
  num / den
}

calc_metrics <- function(obs, pred_label, prob_pos) {
  obs <- factor(obs, levels = CLASS_LEVELS)
  pred_label <- factor(pred_label, levels = CLASS_LEVELS)
  
  roc_obj <- pROC::roc(obs, prob_pos, levels = rev(levels(obs)), quiet = TRUE)
  
  data.frame(
    AUC  = as.numeric(pROC::auc(roc_obj)),
    Sens = caret::sensitivity(pred_label, obs, positive = POS_CLASS),
    Spec = caret::specificity(pred_label, obs, negative = NEG_CLASS),
    F1   = caret::F_meas(pred_label, obs, positive = POS_CLASS),
    MCC  = mcc(pred_label, obs)
  )
}

cat("Loaded: code/binary_rf/00_setup_binary.R\n")