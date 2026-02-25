############################################################
# 08_cv_losocv.R
# LOSO-CV on training set only (requires Sources)
############################################################

if (!exists("train_all")) {
  source("code/binary_rf/01_data_binary.R")
}

assert_required_cols(train_all, c("Sources"))
train_all$Sources <- as.factor(train_all$Sources)

# Use bestTune if available, otherwise fallback
if (exists("fit_rep")) {
  hp <- fit_rep$bestTune
} else {
  hp <- data.frame(mtry = 5, splitrule = "extratrees", min.node.size = 3)
}

source_ids <- levels(droplevels(train_all$Sources))
all_oos <- data.frame()

for (s in source_ids) {
  train_set <- train_all %>% filter(Sources != s)
  fold_test <- train_all %>% filter(Sources == s)
  if (nrow(fold_test) == 0) next
  
  rf_model <- ranger(
    dependent.variable.name = "Attribute",
    data = drop_sources_for_ml(train_set),
    num.trees = N_TREES,
    mtry = hp$mtry,
    min.node.size = hp$min.node.size,
    splitrule = hp$splitrule,
    probability = TRUE
  )
  
  fold_ml <- drop_sources_for_ml(fold_test)
  prob <- predict(rf_model, data = fold_ml)$predictions[, POS_CLASS]
  pred <- factor(ifelse(prob >= 0.5, POS_CLASS, NEG_CLASS), levels = CLASS_LEVELS)
  
  all_oos <- rbind(all_oos, data.frame(
    Source = s,
    True   = fold_ml$Attribute,
    Prob   = prob,
    Pred   = pred
  ))
}

pooled_acc <- mean(all_oos$Pred == all_oos$True)

roc_pooled <- pROC::roc(
  response  = factor(all_oos$True, levels = CLASS_LEVELS),
  predictor = all_oos$Prob,
  levels    = CLASS_LEVELS,
  direction = "<",
  quiet = TRUE
)

pooled_auc <- as.numeric(pROC::auc(roc_pooled))

cat("\nTRAINING-SET LOSO-CV (Pooled)\n")
cat("Pooled Accuracy =", round(pooled_acc, 4), "\n")
cat("Pooled AUC      =", round(pooled_auc, 4), "\n")