############################################################
# 09_permutation_test.R
# Permutation test: shuffle labels + repeated CV AUC/Accuracy
############################################################

if (!exists("df_binary")) {
  source("code/binary_rf/01_data_binary.R")
}

df_perm <- df_binary

set.seed(999)
df_perm$Attribute <- sample(df_perm$Attribute)
df_perm$Attribute <- factor(df_perm$Attribute, levels = CLASS_LEVELS)

split_perm <- make_train_test_split(df_perm, p_train = 0.75, seed = 123)
train_perm <- drop_sources_for_ml(split_perm$train)

ctrl_rep10x10 <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

set.seed(42)
fit_perm <- train(
  Attribute ~ .,
  data = train_perm,
  method = "ranger",
  metric = "ROC",
  trControl = ctrl_rep10x10,
  tuneGrid = expand.grid(mtry = 5, splitrule = "extratrees", min.node.size = 3),
  num.trees = N_TREES
)

pred_perm <- fit_perm$pred
acc_by_fold <- pred_perm %>%
  group_by(Resample) %>%
  summarise(Accuracy = mean(pred == obs), .groups = "drop")

cat("\nPermutation test (shuffled labels):\n")
print(fit_perm$results)
cat("Permutation CV Accuracy =", round(mean(acc_by_fold$Accuracy), 4),
    "±", round(sd(acc_by_fold$Accuracy), 4), "\n")