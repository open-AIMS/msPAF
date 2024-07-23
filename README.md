
<!-- README.md is generated from README.Rmd. Please edit that file -->

# msPAF with ssdtools <img src="man/figures/logo.png" align="right" />

`msPAF` is an R package to obtained additive toxicity estimates based on
2 or more Species Sensitivity Distributions (SSD) obtained via
`ssdtools`.

SSDs are cumulative probability distributions which are fitted to
toxicity concentrations for different species as described by Posthuma
et al. (2001). The current versions of msPAF takes SSDs fitted via the
`ssdtools` package, which uses Maximum Likelihood to fit distributions
such as the gamma, log-logistic, log-normal and Weibull to censored
and/or weighted data.

Joint toxicity of 2 or more contaminants and/or stressors are obtained
following the methods described in Negri, et al. 2019 (Environmental
Science and Technology, 54(2), pp.1102-1110).

## Installation

To install the latest version of `ssdtools` from
[CRAN](https://CRAN.R-project.org/package=ssdtools)

``` r
install.packages("ssdtools")
```

To install the latest development version of `msPAF` from
[GitHub](https://github.com/open-AIMS/msPAF)

``` r
if (!requireNamespace("remotes")) {
  install.packages("remotes")
}
remotes::install_github("open-aims/msPAF", ref = "main")
```

## Introduction

`ssdtools` accesses examples SSD data from the
[ssddata](https://CRAN.R-project.org/package=ssddata) package for a
range of chemicals. We will use the Boron and Cadmium datasets here as a
two component mixture example.

``` r
library(ssdtools)
ssddata::ccme_boron
#> # A tibble: 28 × 5
#>    Chemical Species                  Conc Group        Units
#>    <chr>    <chr>                   <dbl> <fct>        <chr>
#>  1 Boron    Oncorhynchus mykiss       2.1 Fish         mg/L 
#>  2 Boron    Ictalurus punctatus       2.4 Fish         mg/L 
#>  3 Boron    Micropterus salmoides     4.1 Fish         mg/L 
#>  4 Boron    Brachydanio rerio        10   Fish         mg/L 
#>  5 Boron    Carassius auratus        15.6 Fish         mg/L 
#>  6 Boron    Pimephales promelas      18.3 Fish         mg/L 
#>  7 Boron    Daphnia magna             6   Invertebrate mg/L 
#>  8 Boron    Opercularia bimarginata  10   Invertebrate mg/L 
#>  9 Boron    Ceriodaphnia dubia       13.4 Invertebrate mg/L 
#> 10 Boron    Entosiphon sulcatum      15   Invertebrate mg/L 
#> # ℹ 18 more rows
ssddata::ccme_cadmium
#> # A tibble: 36 × 5
#>    Chemical Species                   Conc Group Units
#>    <chr>    <chr>                    <dbl> <fct> <chr>
#>  1 Cadmium  Oncorhynchus mykiss       0.23 Fish  ug/L 
#>  2 Cadmium  Salvelinus confluentus    0.83 Fish  ug/L 
#>  3 Cadmium  Cottus bairdi             0.96 Fish  ug/L 
#>  4 Cadmium  Salmo salar               0.99 Fish  ug/L 
#>  5 Cadmium  Acipenser transmontanus   1.14 Fish  ug/L 
#>  6 Cadmium  Prosopium williamsoni     1.25 Fish  ug/L 
#>  7 Cadmium  Salmo trutta              1.36 Fish  ug/L 
#>  8 Cadmium  Salvelinus fontinalis     2.23 Fish  ug/L 
#>  9 Cadmium  Oncorhynchus tshawytscha  2.29 Fish  ug/L 
#> 10 Cadmium  Pimephales promelas       2.36 Fish  ug/L 
#> # ℹ 26 more rows
```

We start by fitting the default `ssdtools` distributions are fit using
`ssd_fit_dists()`, to create a named list of `ssdtools` `fitdists`
objects for the chemicals for which we want to explore additive
toxicity.

``` r
fits <- list(boron = ssd_fit_dists(ssddata::ccme_boron), 
             cadmium = ssd_fit_dists(ssddata::ccme_cadmium))
             
```

The resulting fitted distributions can be quickly plotted using
`autoplot`

``` r
library(ggplot2)
library(ggpubr)

theme_set(theme_bw())

plot_list <- lapply(fits, FUN = function(p){
  autoplot(p) +
    scale_colour_ssd()  
})

ggarrange(plotlist = plot_list, common.legend = TRUE, labels = names(plot_list))
```

![](man/figures/README-unnamed-chunk-5-1.png)<!-- --> We can obtain
predictions of the additive proportion of species affected across both
chemicals using

``` r
library(msPAF)
plot_dat <- additive_predict(fits)
head(plot_dat)
#>       boron    cadmium additive_proportions
#> 1 0.2672579 0.04833443               0.0199
#> 2 0.5284784 0.04833443               0.0297
#> 3 0.7780124 0.04833443               0.0395
#> 4 1.0167996 0.04833443               0.0493
#> 5 1.2474880 0.04833443               0.0591
#> 6 1.4728905 0.04833443               0.0689
```

For two contaminants, these can be visualized as a surface.

``` r
library(plotly)
z=plot_dat$additive_proportions
y=plot_dat$boron
x=plot_dat$cadmium
dat <- data.frame(z,y,x)
plot_ly(z = ~xtabs(z ~ x + y), data = dat) |> 
  add_surface() 
```

The model-averaged additive 1, 5, 10 and 20% hazard concentration can be
estimated via `additive_hc`. Note that for two contaminants, these form
a curve.

``` r
hc_vals_out <- additive_hc(fits)
hc_vals_out
#> # A tibble: 172 × 3
#>       boron cadmium proportion
#>       <dbl>   <dbl> <fct>     
#>  1 8.11e-14  0.0492 0.01      
#>  2 5.44e- 2  0.0427 0.01      
#>  3 1.11e- 1  0.0356 0.01      
#>  4 1.69e- 1  0.0273 0.01      
#>  5 2.26e- 1  0.0158 0.01      
#>  6 8.11e-14  0.148  0.05      
#>  7 5.44e- 2  0.143  0.05      
#>  8 1.11e- 1  0.138  0.05      
#>  9 1.69e- 1  0.133  0.05      
#> 10 2.26e- 1  0.128  0.05      
#> # ℹ 162 more rows
```

For only two contaminants, these co-dependence curves can easily be
visualized.

``` r
hc_vals_out |> 
  ggplot(aes(x=boron, y=cadmium, colour = proportion)) +
  geom_line() +
  theme_bw()
```

The model-averaged additive hazard proportion values can be obtained via
`additive_hp` by providing the list of fitted SSDs and a named list of
concentrations for each contaminant.

``` r
hp_vals_out <- additive_hp(fits, 
                           conc = list(boron = c(1, 5, 10), 
                                       cadmium = c(0.1, 0.2)))
hp_vals_out
```

## Licensing

Copyright 2018-2024 Province of British Columbia  
Copyright 2021 Environment and Climate Change Canada  
Copyright 2023-2024 Australian Government Department of Climate Change,
Energy, the Environment and Water

The documentation is released under the [CC BY 4.0
License](https://creativecommons.org/licenses/by/4.0/)

The code is released under the [Apache License
2.0](https://www.apache.org/licenses/LICENSE-2.0)
