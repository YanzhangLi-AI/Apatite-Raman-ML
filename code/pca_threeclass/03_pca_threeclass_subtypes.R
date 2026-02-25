############################################################
# 03_pca_threeclass_subtypes.R
# PCA plot:
# - 95% ellipses ONLY for Abiotic & Biotic
# - Synthetic split into 3 subtypes by No, shape+fill coded
############################################################

if (!exists("pca3_df")) {
  source("code/pca_threeclass/01_data_pca3.R")
}

pca3_df2 <- pca3_df %>%
  mutate(
    Synth3 = case_when(
      Attribute == "Synthetic" & No >= 130 & No <= 135 ~ "Synthetic (Amorphous)",
      Attribute == "Synthetic" & No >= 170 & No <= 197 ~ "Synthetic (Carbonated)",
      Attribute == "Synthetic"                         ~ "Synthetic (Others)",
      TRUE ~ NA_character_
    ),
    Synth3 = factor(
      Synth3,
      levels = c("Synthetic (Amorphous)", "Synthetic (Carbonated)", "Synthetic (Others)")
    )
  )

cols_end <- c("Abiotic" = "#5089BC", "Biotic" = "#00B050")

p_pca3_subtypes <- ggplot() +
  # ellipses for Abiotic & Biotic only
  stat_ellipse(
    data = subset(pca3_df2, Attribute %in% c("Abiotic", "Biotic")),
    mapping = aes(x = PC1, y = PC2, color = Attribute, group = Attribute),
    type = "t", level = 0.95, linewidth = 0.9
  ) +
  # Synthetic points with subtype shapes/fills
  geom_point(
    data = subset(pca3_df2, Attribute == "Synthetic"),
    aes(x = PC1, y = PC2, shape = Synth3, fill = Synth3),
    size = 3,
    stroke = 0.6,
    color = "#54534D"
  ) +
  scale_color_manual(values = cols_end, name = NULL) +
  scale_shape_manual(
    values = c(
      "Synthetic (Amorphous)"  = 23,
      "Synthetic (Carbonated)" = 24,
      "Synthetic (Others)"     = 22
    ),
    name = NULL
  ) +
  scale_fill_manual(
    values = c(
      "Synthetic (Amorphous)"  = "pink",
      "Synthetic (Carbonated)" = "orange",
      "Synthetic (Others)"     = "lightgray"
    ),
    name = NULL
  ) +
  theme_bw(base_size = 16) +
  theme(
    legend.position = "none",
    panel.grid = element_blank(),
    axis.title.x = element_text(size = 15, face = "bold"),
    axis.title.y = element_text(size = 15, face = "bold")
  ) +
  labs(
    x = paste0("PC1 (", pc1_pct, "%)"),
    y = paste0("PC2 (", pc2_pct, "%)"),
    title = ""
  )

print(p_pca3_subtypes)