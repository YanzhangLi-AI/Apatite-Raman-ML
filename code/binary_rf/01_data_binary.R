############################################################
# 01_data_binary.R
# Load binary dataset + train/test split
#
# Expected columns:
# - 21 numeric feature columns
# - Attribute (Abiotic/Biotic)
# - Sources (optional; used only for LOSO-CV)
############################################################

if (!exists("CLASS_LEVELS")) {
  source("code/binary_rf/00_setup_binary.R")
}

df_binary <- read.csv(file.choose(), stringsAsFactors = TRUE)

# Binary workflow does not require No; drop if present
df_binary <- df_binary %>% dplyr::select(-any_of("No"))

assert_required_cols(df_binary, c("Attribute"))

df_binary$Attribute <- factor(df_binary$Attribute, levels = CLASS_LEVELS)

cat("\nBinary dataset loaded.\n")
cat("Total N =", nrow(df_binary), "\n")
print(table(df_binary$Attribute))

split <- make_train_test_split(df_binary, p_train = 0.75, seed = SEED_SPLIT)
train_all <- split$train
test_set  <- split$test

cat("\nTrain/Test split (75/25):\n")
cat("Training N =", nrow(train_all), "| Test N =", nrow(test_set), "\n")