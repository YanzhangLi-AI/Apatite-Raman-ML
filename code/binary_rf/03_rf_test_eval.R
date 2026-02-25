############################################################
# 03_rf_test_eval.R
# Train final model (bestTune) + evaluate on test set
############################################################

if (!exists("fit_rep")) {
  source("code/binary_rf/02_rf_repeatedcv.R")
}

final_model <- ranger(
  dependent.variable.name = "Attribute",
  data = drop_sources_for_ml(train_all),
  num.trees = N_TREES,
  mtry = fit_rep$bestTune$mtry,
  min.node.size = fit_rep$bestTune$min.node.size,
  splitrule = fit_rep$bestTune$splitrule,
  probability = TRUE,
  importance = "permutation"
)

test_ml <- drop_sources_for_ml(test_set)

test_prob <- predict(final_model, data = test_ml)$predictions[, POS_CLASS]
test_pred <- factor(ifelse(test_prob >= 0.5, POS_CLASS, NEG_CLASS),
                    levels = CLASS_LEVELS)

test_metrics <- calc_metrics(test_ml$Attribute, test_pred, test_prob)

cat("\nTest set metrics:\n")
print(test_metrics)

cat("\nConfusion Matrix (Test set):\n")
cm_test <- confusionMatrix(test_pred, test_ml$Attribute, positive = POS_CLASS)
print(cm_test)

test_res <- list(
  prob = test_prob,
  pred = test_pred,
  truth = test_ml$Attribute,
  metrics = test_metrics,
  cm = cm_test
)