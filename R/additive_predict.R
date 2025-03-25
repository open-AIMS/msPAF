#' Calculates the additive proportion of the community effected
#'
#' This function calculate the additive proportion of the community effect
#' across two or more input ssds, as input via a named list.
#'
#' @inheritParams params
#' 
#' @export

additive_predict <- function(x, proportion = seq(0.001, 1-0.001, length=100)){
  
  pred_vals <- lapply(x, FUN = function(y){
    pred <- predict(y, proportion = proportion)
  })
  
  prop_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$proportion}))
  hc_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$est}))
  additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod)
  
  out_dat <- cbind(hc_vals, additive_proportions)
}



