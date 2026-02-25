############################################################
# 11_pca_3d_binary.R
# PCA (3D) for binary dataset: Abiotic vs Biotic (interactive)
#
# Requires plotly. This script will install it if missing.
############################################################

# Load binary setup (factor levels + tidyverse)
if (!exists("CLASS_LEVELS")) {
  source("code/binary_rf/00_setup_binary.R")
}

# plotly (install/load here to avoid bloating the core RF setup)
if (!("plotly" %in% rownames(installed.packages()))) install.packages("plotly")
suppressPackageStartupMessages(library(plotly))

# Load data if not already loaded
if (!exists("df_binary")) {
  df_binary <- read.csv(file.choose(), stringsAsFactors = TRUE)
}

stopifnot("Attribute" %in% names(df_binary))
df_binary$Attribute <- factor(df_binary$Attribute, levels = CLASS_LEVELS)

# Feature matrix (numeric only), drop No if present
X <- df_binary %>%
  dplyr::select(where(is.numeric))

if ("No" %in% names(X)) X <- X %>% dplyr::select(-No)

# PCA
pca_res <- prcomp(X, center = TRUE, scale. = TRUE)

var_exp <- (pca_res$sdev^2) / sum(pca_res$sdev^2)
pc1_pct <- round(var_exp[1] * 100, 1)
pc2_pct <- round(var_exp[2] * 100, 1)
pc3_pct <- round(var_exp[3] * 100, 1)

pca_df <- data.frame(
  PC1 = pca_res$x[, 1],
  PC2 = pca_res$x[, 2],
  PC3 = pca_res$x[, 3],
  Attribute = df_binary$Attribute
)

# Colors
cols <- c("Abiotic" = "blue", "Biotic" = "darkgreen")

p_pca3d_bin <- plot_ly(
  data = pca_df,
  x = ~PC1, y = ~PC2, z = ~PC3,
  color = ~Attribute,
  colors = cols,
  type = "scatter3d",
  mode = "markers",
  marker = list(size = 2.5, opacity = 0.85)
) %>%
  layout(
    scene = list(
      xaxis = list(title = paste0("PC1 (", pc1_pct, "%)")),
      yaxis = list(title = paste0("PC2 (", pc2_pct, "%)")),
      zaxis = list(title = paste0("PC3 (", pc3_pct, "%)"))
    ),
    legend = list(title = list(text = ""))
  )

p_pca3d_bin

# Optional: top contributors to PC3
pca_load <- pca_res$rotation
pc3_top <- sort(abs(pca_load[, 3]), decreasing = TRUE)[1:min(5, nrow(pca_load))]
cat("\nTop contributors to PC3:\n"); print(pc3_top)