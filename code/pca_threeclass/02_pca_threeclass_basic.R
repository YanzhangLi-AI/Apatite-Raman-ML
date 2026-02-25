############################################################
# 02_pca_threeclass_basic.R
# PCA plot: 3 endmembers with 95% confidence ellipses
############################################################

if (!exists("pca3_df")) {
  source("code/pca_threeclass/01_data_pca3.R")
}

cols <- c(
  "Abiotic"   = "blue",
  "Synthetic" = "lightgrey",
  "Biotic"    = "darkgreen"
)

p_pca3_basic <- ggplot(pca3_df, aes(x = PC1, y = PC2, color = Attribute)) +
  geom_point(alpha = 0.75, size = 3.2) +
  stat_ellipse(type = "t", level = 0.95, linewidth = 0.9) +
  scale_color_manual(values = cols) +
  theme_bw(base_size = 16) +
  theme(
    panel.grid = element_blank(),
    legend.title = element_blank()
  ) +
  labs(
    x = paste0("PC1 (", pc1_pct, "%)"),
    y = paste0("PC2 (", pc2_pct, "%)"),
    title = ""
  )

print(p_pca3_basic)