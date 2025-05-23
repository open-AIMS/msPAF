#' Parameter Descriptions for msPAF Functions
#' 
#' @param x A named list of ssd's of class "fitdists" as fitted by 
#' \code{\link{ssd_fit_dists}} via package \code{\link{ssdtools}}. Alternatively,
#' a named list of concentration-response fits of class "bnecfit" as fitted by 
#' \code{\link{bnec}} via package \code{\link{bayesnec}}.
#' @param conc A names list of numeric vectors of concentrations to calculate 
#' the hazard proportions for.
#' @param proportion A numeric vector of proportion values to estimate hazard 
#' concentrations for. These are proportion of the community in the case of a
#' fitted ssd, or effect proportions relative to the control in the case of a 
#' concentration-response fitted model.
#' @param resolution The number of values over which to find estimates
#' large values will make the estimate more precise but will also be slow to run.
#' @param diff_error Percentage error in estimated additive_proportion affected
#' considered acceptable as a valid HC estimate.
#' @param fixed_conc List of concentrations series to use for additive HC 
#' estimation.
#' @param fixed_prop List of fixed proportions, or proportion series to use 
#' for additive HC estimation.
#' @param expand Should fixed concentrations be expanded to include all 
#' combinations of values supplied, or should these be used as specific
#' combinations only.
#' @name params
NULL


