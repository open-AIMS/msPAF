#' Calculates the additive proportion effected given concentrations of two or 
#' more intoxicants.
#' 
#' @details
#' This function calculates the additive proportion of the community effected, or
#' additive individual species endpoint response effect
#' across two or more input ssds, or input concentration response models, 
#' as input via a named list.
#'
#' @inheritParams params
#' 
#' @importFrom dplyr mutate select
#' @importFrom tidyr expand_grid
#' 
#' @export
additive_hp <- function(x, fixed_conc, expand = TRUE, ci = FALSE, ...){
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
    hp_fun(fit.y, conc = conc.y) |> 
      mutate(proportion=est) |> 
      select(conc, proportion)
  }) 
  names(hp_vals) <- comp_x

  if(expand) {
    prop_vals <- expand.grid(lapply(hp_vals, FUN = function(y){y$proportion}))
    hc_vals <- expand.grid(lapply(hp_vals, FUN = function(y){y$conc}))
    additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod)
    out_dat <- cbind(hc_vals, additive_proportions)    
  } else {
    prop_vals <- bind_cols(lapply(1:length(hp_vals), FUN = function(y){
      dat_out <- data.frame(proportion=hp_vals[[y]]$proportion)
      colnames(dat_out) <- paste(names(hp_vals)[y], "_P", sep="")
      dat_out
      })) 
    hc_vals <- bind_cols(lapply(1:length(hp_vals), FUN = function(y){
      dat_out <- data.frame(conc=hp_vals[[y]]$conc)
      colnames(dat_out) <- names(hp_vals)[y]
      dat_out
    })) 
    additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod)
    out_dat <- cbind(hc_vals, additive_proportions)     
  }

  return(out_dat)
}



