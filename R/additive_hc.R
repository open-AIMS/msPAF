#' Calculates the additive proportion of the community effected
#'
#' This function calculate the additive proportion of the community effect
#' across two or more input ssds, as input via a named list.
#'
#' @inheritParams params
#' 
#' @importFrom ssdtools predict
#' @importFrom dplyr mutate select
#' @importFrom modelbased zero_crossings
#' 
#' @export


additive_hc <- function(x, proportion = c(0.01, 0.05, 0.1, 0.2), resolution = 100){
  cols <- c(names(x), "additive_proportions")

  pred_vals <- lapply(x, FUN = function(y){
  predict(y, proportion = seq(min(proportion^length(y))/resolution, 
                             max(proportion)+1/resolution, length=resolution))
  })

  prop_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$proportion}))
  hc_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$est}))
  additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod)
  
  hc_dat <- cbind(hc_vals, additive_proportions)  
  hc_out <-  lapply(proportion, FUN = function(p){
    hc_dat |> 
      mutate(diff_vals=additive_proportions-p) |>
      mutate(proportion=as.factor(p))
  }) |> bind_rows()
  
  pc_vals_list <- hc_out |>
    group_split(proportion)
  
  hc_vals_out <- lapply(pc_vals_list, FUN = function(y){
    y <- y |> arrange_all(.vars = cols) 
    indices <- find_switches(y$diff_vals)
    t(sapply(indices, FUN = function(z){
      dat.z <- y[c(z-1, z),]
      zc.z <- zero_crossings(dat.z$diff_vals)/2
      weights.z <- c(1-zc.z, zc.z)
      apply(dat.z[,cols[-length(cols)]], MARGIN=2, FUN = weighted.mean, w=weights.z)
    })) |> bind_cols(y[indices, "proportion"])
  }) |> bind_rows()


}




