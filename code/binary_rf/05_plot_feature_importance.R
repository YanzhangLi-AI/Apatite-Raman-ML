############################################################
# 05_plot_feature_importance.R
# Permutation feature importance (Top 10)
############################################################

if (!exists("fit_rep")) {
  source("code/binary_rf/02_rf_repeatedcv.R")
}

imp <- fit_rep$finalModel$variable.importance
if (is.null(imp)) stop("variable.importance is NULL. Ensure importance='permutation' in training.")

top_n <- 10
imp_top <- sort(imp, decreasing = TRUE)[1:min(top_n, length(imp))]

df_imp <- data.frame(
  Variable = factor(names(imp_top), levels = rev(names(imp_top))),
  Importance = as.numeric(imp_top)
)

p_importance <- ggplot(df_imp, aes(x = reorder(Variable, Importance), y = Importance)) +
  geom_col() +
  coord_flip() +
  theme_bw(base_size = 14) +
  theme(panel.grid = element_blank()) +
  labs(title = "", x = "Variable", y = "Permutation importance")

print(p_importance)