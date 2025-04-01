#' Extracts the hazard concentration given the proportion effect
#' 
#' @inheritParams params
#' 
#' @importFrom ssdtools predict
#' 
#' @export
predict_fun <- function(x, proportion, ...){
  UseMethod("predict_fun")
}

#' @noRd
#'
#' @export
predict_fun.fitdists <- function(x, proportion, ...){
  predict(x, proportion = proportion, ...)
}

#' @noRd
#'
#' @export
predict_fun.bnecfit <- function(x, proportion = proportion, ...){
  hc_fun(x, proportion = proportion, ...) 
}

