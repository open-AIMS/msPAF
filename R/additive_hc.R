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
additive_hc <- function(x, proportion = c(0.01, 0.05, 0.1, 0.2), 
                        resolution = 100, diff_error=1, 
                        fixed_prop = NA, fixed_conc = NA){
  names_all <- names(x)
  names_fixedP <- names(fixed_prop) 
  names_fixedC <- names(fixed_conc)  

  names_fixed <- union(names_fixedP, names_fixedC)
  names_free <- setdiff(names_all, names_fixed)

  if(!is.null(names_fixed)){
    if(length(setdiff(names_fixed, names_all))>0){
      stop("Your fixed names are not present in x")
    }
  }
  
  if(!is.null(names_fixedC)){
    fixed_prop_add <- lapply(names_fixedC, FUN = function(k){
      ssd_hp(x[[k]], conc = fixed_conc[[k]])$est/100
    })
    names(fixed_prop_add) <- names_fixedC 
    
    if(is.null(names_fixedP)){
      fixed_prop <- fixed_prop_add
    } else {
      keys <- unique(c(names(fixed_prop), names(fixed_prop_add)))
      fixed_prop <- setNames(mapply(c, fixed_prop[keys], fixed_prop_add[keys]), keys)        
    }
  }

  cols <- c(names_all, "additive_proportions")
  hc_vals_out <- lapply(proportion, FUN = function(p){ 
    pred_vals <-   lapply(names_all, FUN = function(y){
      y_fit <- x[[y]]

      if(is.null(names_fixed)){
        predict(y_fit, proportion = seq(0, p*1.1, length = resolution))           
      } else {
        if(is.null(fixed_prop[[y]])){
          predict(y_fit, proportion = seq(0, p*1.1, length = resolution)) 
        } else {
          predict(y_fit, proportion = fixed_prop[[y]])          
        }
      }
    }) 
    names(pred_vals) <- names_all
      
    prop_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$proportion}))
    hc_vals <- expand.grid(lapply(pred_vals, FUN = function(y){y$est}))
    additive_proportions <- 1 - apply(1-prop_vals, MARGIN = 1, prod) 
    hc_dat <- cbind(hc_vals, additive_proportions)  
    
    tt <- hc_dat |> 
          mutate(diff_vals=(additive_proportions-p)/p) |>
          mutate(proportion=as.factor(p))|> arrange_all(.vars = cols) 
   
    hc_vals_out <- lapply(names_free, FUN = function(l){
        tt_l <- tt
        if(is.null(dim(tt[, setdiff(names_all, l)]))) {
          tt_l$fact_x <- as.factor(tt[, setdiff(names_all, l)])          
        } else {
          tt_l$fact_x <- as.factor(do.call("paste", tt[, setdiff(names_all, l)]))          
        }

        tt_list <- tt_l |> 
          group_split(fact_x)
        tt_list_out <- lapply(tt_list, FUN = function(k){
          z <-which((c(diff(sign(k$diff_vals)), 0) != 0))
          if(length(z)>0){
            
              dat.z <- k[c(z, z+1),]
              zc.z <- zero_crossings(dat.z$diff_vals)/2
              weights.z <- c(zc.z, zc.z+1)
                apply(dat.z[, cols], 
                      MARGIN=2, FUN = weighted.mean, w=weights.z)                
              
             } else {
               if(min(k$diff_vals)<(diff_error/100)){
                 k[which.min(k$diff_vals), cols]                 
               }
                 k[0, cols]                    
             }            
        }) |> 
          na.omit() |> 
          bind_rows()|> 
          dplyr::filter((abs(additive_proportions-p)/p)<(diff_error/100)) |> 
          mutate(proportion = as.factor(p))          
      }) |> bind_rows()       
  }) |> bind_rows()
}




