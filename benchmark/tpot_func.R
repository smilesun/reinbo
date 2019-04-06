source("system.R")
tpot = import("tpot")
opt.tpot = function(task, budget, measure, train_set) {
  conf_tpot = getGconf()$conf_tpot
  pipeline_optimizer = tpot$TPOTClassifier(generations = conf_tpot$generations, population_size = conf_tpot$population_size,
                                           offspring_size = conf_tpot$offspring_size, cv = getGconf()$NCVInnerIter,
                                           config_dict = conf_tpot$config_dict)
  train_data = getTaskData(task, train_set, target.extra = TRUE)
  pipeline_optimizer$fit(train_data$data, as.numeric(train_data$target))
  return(pipeline_optimizer)
}

lock_eval.tpot = function(task, measure = NULL, train_set = NULL, test_set, best_model) {
  test_data = getTaskData(task, test_set, target.extra = TRUE)
  mpred = 1 - best_model$score(test_data$data, as.numeric(test_data$target))
  return(mpred)
}