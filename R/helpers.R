


find_switches <-function(x){
  which((c(0, diff(sign(x))) != 0)==TRUE & c(0, abs(diff(x)))<0.1)
}


