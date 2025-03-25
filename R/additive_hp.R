#' Calculates the additive proportion of the community effected
#'
#' This function calculate the additive proportion of the community effect
#' across two or more input ssds, as input via a named list.
#'
#' @inheritParams params
#' 
#' @importFrom ssdtools ssd_hp
#' @importFrom dplyr mutate select
#' 
#' @export

additive_hp <- function(x, fixed_conc, ci = FALSE, ...){
  comp_x <- names(x)

  if(is.null(comp_x)){
    stop("x must be must be a named list")
  }
  
  if(is.null(fixed_conc)){
    stop("fixed_conc must be must be a named list")
  }
  
  comp_conc <- names(fixed_conc)  
  
  if(length(na.omit(match(comp_x, comp_conc))) != length(x)) {
    stop("fixed_conc must contain values for all elements of x")
  }

  hp_vals <- lapply(1:length(comp_x), FUN = function(y){
    name.y <- comp_x[y]
    fit.y <- x[[name.y]]
    conc.y <- fixed_conc[[name.y]]
    ssd_hp(fit.y, conc = conc.y) |> 
      mutate(proportion=est/100) |> 
      select(conc, proportion)
  }) 
  names(hp_vals) <- comp_x
  
  prop_vals <- expand.grid(lapply(hp_vals, FUN = function(y){y$proportion}))
  hc_vals <- expand.grid(lapply(hp_vals, FUN = function(y){y$conc}))
  additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod)
  out_dat <- cbind(hc_vals, additive_proportions)
}



