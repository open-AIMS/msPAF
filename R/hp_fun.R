#' Extracts the proportion effected given a defined toxicant concentration.
#' 
#' @details
#' This function calculates the proportion effected given a concentration of
#' a toxicant. In the case of an SSD, this returns the proportion of the 
#' community effected. In the case of concentration-response fit, this returns
#' the proportional effect on the endpoint, relative to control.
#' 
#' @inheritParams params
#' 
#' @importFrom ssdtools ssd_hc
#' @importFrom bayesnec bnec_newdata 
#' @importFrom brms posterior_epred
#' @importFrom dplyr bind_rows filter select mutate
#' @importFrom tibble rownames_to_column
#' @importFrom tidyr pivot_longer pivot_wider
#' 
#' @export
hp_fun <- function(x, conc, ...){
  UseMethod("hp_fun")
}

#' @noRd
#'
#' @export
hp_fun.fitdists <- function(x, conc, ...){
  ssd_hp(x, conc = conc, ...) |> 
    mutate(est=est/100)
}

#' @noRd
#'
#' @export
hp_fun.bnecfit <- function(x, conc, type = "absolute", ...){

  if(length(conc)<2) { 
    stop("hp_fun only currently supports calculates for two or more concentratiolns")
    }
  
  bnec_dat <- bnec_newdata(x, resolution = 2)
  var_names <- colnames(bnec_dat)
  if(length(var_names)==2){
    conc_dat <- data.frame(conc, tot = 1)
  } else {
    conc_dat <- data.frame(conc)
  }
  colnames(conc_dat) <- var_names   

  new_dat_limits <- bnec_dat
  new_dat <- conc_dat
  
  pred_vars_limits <- apply(posterior_epred(object = x, newdata = new_dat_limits,
                                     re_formula = NA), 
                     MARGIN = 2, FUN = quantile, probs = c(0.025, 0.5, 0.975))
  pred_vars <- apply(posterior_epred(object = x, newdata = new_dat,
                               re_formula = NA), 
                     MARGIN = 2, FUN = quantile, probs = c(0.025, 0.5, 0.975))
  rownames(pred_vars_limits) <- c("lcl", "est", "ucl")  
  rownames(pred_vars) <- c("lcl", "est", "ucl")
  
  pred_dat <- pred_vars |>  
    data.frame() |>
    rownames_to_column(var="estimate") |> 
    pivot_longer(cols = starts_with("X"), names_to = "names", values_to = "value") |> 
    mutate(names=as.numeric(gsub("X", "", names))) 
  pred_dat$conc <- new_dat[pred_dat$names, 1]
  
  control_dat <- pred_vars_limits |>  
    data.frame() |>
    rownames_to_column(var="estimate") |> 
    pivot_longer(cols = starts_with("X"), names_to = "names", values_to = "value") |> 
    mutate(names=as.numeric(gsub("X", "", names))) 
  control_dat$conc <- new_dat_limits[control_dat$names, 1]
  
  control_val <- control_dat |> 
    filter(estimate=="est" & conc == min(conc)) |> 
    select(value) |> 
    unlist()
  min_val <- control_dat |> 
    filter(estimate=="est" & conc == max(conc)) |> 
    select(value) |> 
    unlist()
  
  if(type == "absolute") { min_val <- 0 } 
  
  dif_val <- control_val-min_val
  pred_dat |> 
    select(estimate, value, conc) |> 
    mutate(proportion=(1-(value - min_val)/dif_val)) |> 
    #mutate(proportion = round(proportion, 2)) |> # round to nearest 1% 
    mutate(proportion=ifelse(proportion<0, 0, proportion)) |> # deal with values outside control and hormesis
    select(estimate, proportion, conc) |>  
    pivot_wider(names_from = estimate, values_from = proportion)

}

