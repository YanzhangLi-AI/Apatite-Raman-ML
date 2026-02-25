############################################################
# 07_cv_loocv.R
# LOOCV on training set only
############################################################

if (!exists("train_all")) {
  source("code/binary_rf/01_data_binary.R")
}

train_ml <- drop_sources_for_ml(train_all)

# Use bestTune if available, otherwise fallback
if (exists("fit_rep")) {
  hp <- fit_rep$bestTune
} else {
  hp <- data.frame(mtry = 5, splitrule = "extratrees", min.node.size = 3)
}

ctrl_loocv <- trainControl(
  method = "LOOCV",
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

set.seed(42)
fit_loocv <- train(
  Attribute ~ .,
  data = train_ml,
  method = "ranger",
  metric = "ROC",
  trControl = ctrl_loocv,
  tuneGrid = expand.grid(mtry = hp$mtry, splitrule = hp$splitrule, min.node.size = hp$min.node.size),
  num.trees = N_TREES,
  importance = "permutation"
)

pred_loocv <- fit_loocv$pred
acc_loocv <- mean(pred_loocv$pred == pred_loocv$obs)

cat("\nLOOCV results:\n")
print(fit_loocv$results)
cat("LOOCV Accuracy =", round(acc_loocv, 4), "\n")