#' Extracts the hazard concentration given the proportion effected.
#' 
#' @details
#' This function calculates the hazard concentration, given a desired
#' proportion of the community effected or individual species endpoint effect. 
#' 
#' @inheritParams params
#' 
#' @importFrom ssdtools ssd_hc
#' @importFrom toxval ecx
#' @importFrom tidyr pivot_wider
#' @importFrom tibble rownames_to_column
#' @importFrom dplyr mutate
#' 
#' @export
hc_fun <- function(x, proportion, ...){
  UseMethod("hc_fun")
}

#' @noRd
#'
#' @export
hc_fun.fitdists <- function(x, proportion, ...){
  ssd_hc(x, proportion = proportion, ...)
}

#' @noRd
#'
#' @export
hc_fun.bnecfit <- function(x, proportion, ...){
  vals_out <- ecx(x, ecx_val = proportion * 100, ...)
  rownames(vals_out) <- c("est", "lcl", "ucl")
  vals_out |>  
    data.frame() |>
    rownames_to_column(var="estimate") |> 
    pivot_longer(cols = starts_with("X"), names_to = "proportion", values_to = "value") |> 
    mutate(proportion=as.numeric(gsub("X", "", proportion))/100) |> 
    pivot_wider(names_from = estimate, values_from = value)
} 
