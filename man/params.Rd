% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/params.R
\name{params}
\alias{params}
\title{Parameter Descriptions for msPAF Functions}
\arguments{
\item{x}{A named list of ssd's of class "fitdists" as fitted by
\code{\link{ssd_fit_dists}} via package \code{\link{ssdtools}}.}

\item{conc}{A names list of numeric vectors of concentrations to calculate
the hazard proportions for.}

\item{proportion}{A numeric vector of proportion values to estimate hazard
concentrations for.}

\item{resolution}{The number of values over which to find estimates
large values will make the estimate more precise but will also be slow to run.}

\item{diff_error}{Percentage error in estimated additive_proportion affected
considered acceptable as a valid HC estimate}

\item{fixed_conc}{List of concentrations series to use for additive HC
estimation}

\item{fixed_prop}{List of fixed proportions, or proportion series to use
for additive HC estimation}
}
\description{
Parameter Descriptions for msPAF Functions
}
