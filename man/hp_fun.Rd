% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hp_fun.R
\name{hp_fun}
\alias{hp_fun}
\title{Extracts the proportion effected given a defined toxicant concentration.}
\usage{
hp_fun(x, conc, ...)
}
\arguments{
\item{x}{A named list of ssd's of class "fitdists" as fitted by
\code{\link{ssd_fit_dists}} via package \code{\link{ssdtools}}. Alternatively,
a named list of concentration-response fits of class "bnecfit" as fitted by
\code{\link{bnec}} via package \code{\link{bayesnec}}.}

\item{conc}{A names list of numeric vectors of concentrations to calculate
the hazard proportions for.}
}
\description{
Extracts the proportion effected given a defined toxicant concentration.
}
\details{
This function calculates the proportion effected given a concentration of
a toxicant. In the case of an SSD, this returns the proportion of the
community effected. In the case of concentration-response fit, this returns
the proportional effect on the endpoint, relative to control.
}
