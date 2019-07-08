# Objective to optimize:
toy_smac_obj = function(cfg) {
  print(cfg)
  runif(1)
}
smac_objective = function(cfg) {
  # some variables are defined in the scope where this function is called
  model_index <<- model_index + 1
  model_list[[model_index]] <<- cfg
  lrn = gen_mlrCPOPipe_from_smac_cfg(cfg)
  perf = resample(lrn, subTask, resampling = inner_loop, measures = measure, show.info = FALSE)$aggr
  perf_list <<- c(perf_list, as.numeric(perf))
  return(perf)
}



