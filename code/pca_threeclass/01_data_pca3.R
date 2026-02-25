############################################################
# 01_data_pca3.R
# Load three-class PCA dataset (331)
#
# Expected columns:
# - numeric feature columns
# - Attribute (Abiotic / Synthetic / Biotic)
# - No (required for synthetic subtype rules)
#
# Note: No is retained for subtype rules, but excluded from PCA feature matrix.
############################################################

if (!("ggplot2" %in% loadedNamespaces())) {
  source("code/pca_threeclass/00_setup_pca3.R")
}

df_pca3 <- read.csv(file.choose(), stringsAsFactors = TRUE)

# Must have these columns
req <- c("Attribute", "No")
miss <- setdiff(req, colnames(df_pca3))
if (length(miss) > 0) stop("Missing columns: ", paste(miss, collapse = ", "))

df_pca3$Attribute <- factor(df_pca3$Attribute, levels = c("Abiotic", "Synthetic", "Biotic"))
df_pca3$No <- as.integer(as.character(df_pca3$No))

cat("\nThree-class dataset loaded.\n")
cat("Total N =", nrow(df_pca3), "\n")
print(table(df_pca3$Attribute))

# ---- PCA feature matrix: numeric only, drop No ----
X_pca3 <- df_pca3 %>% dplyr::select(where(is.numeric))
if ("No" %in% names(X_pca3)) X_pca3 <- X_pca3 %>% dplyr::select(-No)

pca3_res <- prcomp(X_pca3, center = TRUE, scale. = TRUE)

var_exp <- (pca3_res$sdev^2) / sum(pca3_res$sdev^2)
pc1_pct <- round(var_exp[1] * 100, 1)
pc2_pct <- round(var_exp[2] * 100, 1)

pca3_df <- tibble(
  PC1 = pca3_res$x[, 1],
  PC2 = pca3_res$x[, 2],
  Attribute = df_pca3$Attribute,
  No = df_pca3$No
)