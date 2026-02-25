############################################################
# 04_plot_confusion_matrix.R
# Confusion matrix heatmap (test set)
############################################################

if (!exists("test_res")) {
  source("code/binary_rf/03_rf_test_eval.R")
}

cm <- confusionMatrix(test_res$pred, test_res$truth, positive = POS_CLASS)

cm_df <- as.data.frame(cm$table)
colnames(cm_df) <- c("Predicted", "True", "Freq")

cm_df <- cm_df %>%
  group_by(True) %>%
  mutate(Percent = Freq / sum(Freq) * 100) %>%
  ungroup()

cm_df$Label <- sprintf("%d\n(%.1f%%)", cm_df$Freq, cm_df$Percent)

cm_df$True <- factor(cm_df$True, levels = CLASS_LEVELS)
cm_df$Predicted <- factor(cm_df$Predicted, levels = CLASS_LEVELS)

p_confusion <- ggplot(cm_df, aes(x = True, y = Predicted, fill = Freq)) +
  geom_tile(color = "grey90", linewidth = 0.6) +
  geom_text(aes(label = Label), size = 6, fontface = "bold") +
  coord_equal() +
  theme_bw(base_size = 14) +
  theme(panel.grid = element_blank()) +
  labs(title = "", x = "True Class", y = "Predicted Class", fill = "Count")

print(p_confusion)