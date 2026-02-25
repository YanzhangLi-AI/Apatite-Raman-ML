############################################################
# 00_setup_pca3.R
# Three-class PCA workflow: packages and settings
############################################################

required_pkgs <- c("tidyverse", "ggplot2", "plotly")

to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install) > 0) install.packages(to_install)

suppressPackageStartupMessages({
  library(tidyverse)
  library(ggplot2)
  library(plotly)
})

cat("Loaded: code/pca_threeclass/00_setup_pca3.R\n")