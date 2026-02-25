############################################################
# 06_plot_pdp_ice.R
# PDP + ICE for a selected feature (example: W7)
############################################################

if (!exists("final_model")) {
  source("code/binary_rf/03_rf_test_eval.R")
}

train_ml <- drop_sources_for_ml(train_all)
train_x  <- train_ml %>% dplyr::select(-Attribute)

pred_fun_biotic <- function(model, newdata) {
  p <- predict(model, data = newdata)$predictions
  as.numeric(p[, POS_CLASS])
}

predictor_biotic <- Predictor$new(
  model = final_model,
  data  = train_x,
  y     = train_ml$Attribute,
  predict.function = pred_fun_biotic
)

plot_ice_pdp <- function(varname, xlab = NULL) {
  if (is.null(xlab)) xlab <- varname
  
  ice_obj <- FeatureEffect$new(predictor_biotic, feature = varname, method = "ice")
  pdp_obj <- FeatureEffect$new(predictor_biotic, feature = varname, method = "pdp")
  
  df_ice <- ice_obj$results
  df_pdp <- pdp_obj$results
  
  ggplot() +
    geom_line(data = df_ice,
              aes(x = .data[[varname]], y = .value, group = .id),
              alpha = 0.25) +
    geom_line(data = df_pdp,
              aes(x = .data[[varname]], y = .value),
              linewidth = 1.2) +
    theme_bw(base_size = 14) +
    theme(panel.grid = element_blank()) +
    labs(x = xlab, y = "Biotic probability", title = "")
}

get_threshold_from_pdp <- function(varname) {
  pdp_obj <- FeatureEffect$new(predictor_biotic, feature = varname, method = "pdp")
  df_pdp <- pdp_obj$results
  df_pdp <- df_pdp[order(df_pdp[[varname]]), ]
  
  dx <- diff(df_pdp[[varname]])
  dy <- diff(df_pdp$.value)
  slope <- dy / dx
  
  idx_thr <- which.max(abs(slope))
  thr <- df_pdp[[varname]][idx_thr + 1]
  
  list(variable = varname, threshold = thr, pdp = df_pdp, slope = slope)
}

# ---- Example ----
# p <- plot_ice_pdp("W7", xlab = "FWHM of Band 7")
# print(p)
# thr <- get_threshold_from_pdp("W7")
# print(thr$threshold)