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

additive_hp <- function(x, conc, ...){
  comp_x <- names(x)
  comp_conc <- names(conc)  
  
  if(is.null(comp_x)){
    stop("x must be must be a named list")
  }
  
  if(is.null(comp_x)){
    stop("conc must be must be a named list")
  }
  
  hp_vals <- lapply(1:length(comp_x), FUN = function(y){
    name.y <- comp_x[y]
    fit.y <- x[[name.y]]
    conc.y <- conc[[name.y]]
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



