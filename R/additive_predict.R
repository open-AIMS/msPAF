#' Calculates the additive hazard concentrations of one or more input toxicants
#' across a range of proportions effected.
#'
#' @details
#' This function calculates the additive hazard concentrations, for a give
#' proportion of the community effected or individual species endpoint effect 
#' values across two or more input ssds or concentration-response curves, 
#' as input via a named list.
#' 
#' @inheritParams params
#' 
#' @export
additive_predict <- function(x, proportion = 1:99/100){
  
  pred_vals <- lapply(x, FUN = function(y){
    pred <- predict_fun(y, proportion = proportion)
  })
  
  prop_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$proportion}))
  hc_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$est}))
  additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod)
  
  out_dat <- cbind(hc_vals, additive_proportions)
}



