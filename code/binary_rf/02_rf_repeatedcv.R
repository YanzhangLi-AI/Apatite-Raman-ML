############################################################
# 02_rf_repeatedcv.R
# Repeated 10x10 CV with tuning (training set only)
############################################################

if (!exists("train_all")) {
  source("code/binary_rf/01_data_binary.R")
}

train_ml <- drop_sources_for_ml(train_all)

ctrl_rep10x10 <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

tune_grid <- expand.grid(
  mtry = c(3, 4, 5),
  splitrule = c("gini", "extratrees"),
  min.node.size = c(3, 5, 10)
)

set.seed(SEED_TRAIN)
fit_rep <- train(
  Attribute ~ .,
  data = train_ml,
  method = "ranger",
  trControl = ctrl_rep10x10,
  metric = "ROC",
  tuneGrid = tune_grid,
  num.trees = N_TREES,
  importance = "permutation"
)

cat("\nBest tuning parameters:\n")
print(fit_rep$bestTune)

# ---- summarize 100 resamples (mean ± sd) ----
pred_cv_best <- fit_rep$pred %>%
  dplyr::filter(
    mtry == fit_rep$bestTune$mtry,
    min.node.size == fit_rep$bestTune$min.node.size,
    splitrule == fit_rep$bestTune$splitrule
  )

fold_metrics <- pred_cv_best %>%
  group_by(Resample) %>%
  summarise(
    AUC  = as.numeric(pROC::auc(pROC::roc(obs, .data[[POS_CLASS]], quiet = TRUE))),
    Sens = caret::sensitivity(pred, obs, positive = POS_CLASS),
    Spec = caret::specificity(pred, obs, negative = NEG_CLASS),
    F1   = caret::F_meas(pred, obs, positive = POS_CLASS),
    MCC  = mcc(pred, obs),
    Accuracy = mean(pred == obs),
    .groups = "drop"
  )

cv_summary <- fold_metrics %>%
  summarise(across(c(AUC, Sens, Spec, F1, MCC, Accuracy),
                   list(mean = mean, sd = sd),
                   .names = "{.col}_{.fn}"))

cat("\nRepeated 10x10 CV summary (mean ± sd across 100 resamples):\n")
print(cv_summary)