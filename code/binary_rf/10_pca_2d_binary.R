############################################################
# 10_pca_2d_binary.R
# PCA (2D) for binary dataset: Abiotic vs Biotic
#
# Input: the same CSV used for binary RF workflow
# - Numeric feature columns (21 features)
# - Attribute (Abiotic/Biotic)
# - Sources (optional; ignored here)
# - No (optional; ignored here)
############################################################

# Load binary setup if needed (for tidyverse/ggplot2 and factor levels)
if (!exists("CLASS_LEVELS")) {
  source("code/binary_rf/00_setup_binary.R")
}

# Load data if not already loaded
if (!exists("df_binary")) {
  df_binary <- read.csv(file.choose(), stringsAsFactors = TRUE)
}

# Ensure label factor order
stopifnot("Attribute" %in% names(df_binary))
df_binary$Attribute <- factor(df_binary$Attribute, levels = CLASS_LEVELS)

# Build feature matrix:
# - keep numeric columns
# - explicitly drop non-feature numeric columns such as No if present
X <- df_binary %>%
  dplyr::select(where(is.numeric))

if ("No" %in% names(X)) X <- X %>% dplyr::select(-No)

# PCA (center + scale)
pca_res <- prcomp(X, center = TRUE, scale. = TRUE)

var_exp <- (pca_res$sdev^2) / sum(pca_res$sdev^2)
pc1_pct <- round(var_exp[1] * 100, 1)
pc2_pct <- round(var_exp[2] * 100, 1)

pca_df <- tibble::tibble(
  PC1 = pca_res$x[, 1],
  PC2 = pca_res$x[, 2],
  Attribute = df_binary$Attribute
)

# Colors (match your earlier style)
cols <- c("Abiotic" = "blue", "Biotic" = "darkgreen")

p_pca2d_bin <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Attribute)) +
  geom_point(alpha = 0.75, size = 3) +
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

print(p_pca2d_bin)

# Optional: print top contributors (loadings) for PC1/PC2
pca_load <- pca_res$rotation
pc1_top <- sort(abs(pca_load[, 1]), decreasing = TRUE)[1:min(5, nrow(pca_load))]
pc2_top <- sort(abs(pca_load[, 2]), decreasing = TRUE)[1:min(5, nrow(pca_load))]

cat("\nTop contributors to PC1:\n"); print(pc1_top)
cat("\nTop contributors to PC2:\n"); print(pc2_top)