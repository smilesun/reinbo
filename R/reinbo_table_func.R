# ML_ReinBo algorithm:
opt.reinbo.table = function(task, budget, measure, init_val, train_set = NULL, conf, ctrl) {
  subTask = task
  if (!is.null(train_set)) subTask = subsetTask(task, train_set)
  inner_loop = makeResampleInstance("CV", iters = getGconf()$NCVInnerIter, stratify = TRUE, subTask)
  env = runQTable(subTask, budget, measure, inner_loop, init_val, conf, ctrl)
  mmodel = getBestModel(env$mbo_cache)
  return(list(mmodel = mmodel, env = env))
}

# Predict function: evaluate best model on test dataset
lock_eval.reinbo.table = function(task, measure, train_set, test_set, best_model){
  best_model = best_model$mmodel
  lrn = genLearnerForBestModel(task, best_model, measure)
  mod = train(lrn, task, subset = train_set)
  pred = predict(mod, task, subset = test_set)
  perf = performance(pred, measures = measure)
  return(perf)
}


# Reinforcement learning part:
#' @param ctrl pipeline configuration
runQTable <- function(task, budget, measure, instance, init_val, conf, ctrl) {
  env = Q_table_Env$new(task, budget, measure, instance, ctrl)
  agent = initAgent(name = "AgentTable", env = env, conf = conf, q_init = init_val,
                    state_names = ctrl$g_state_names,
                    act_names_per_state = get_act_names_perf_state(ctrl$g_operators),
                    vis_after_episode = FALSE)
  agent$learn(getGconf()$RLMaxEpisode)
  return(env)
}

# MBO function: hyperparameter tuning
#' @param model character vector
mbo_fun = function(task, model, design, measure, cv_instance, ctrl) {
  ps = g_getParamSetFun(model)  # get parameter set from string representation of a model
  object = makeSingleObjectiveFunction(
    fn = function(x) {
      -reinbo_mlr_fun(task, model, x, measure, cv_instance) + runif(1)/100000
    },
    par.set = ps,
    has.simple.signature = FALSE,
    minimize = FALSE
  )
  ctrlmbo = setMBOControlTermination(makeMBOControl(), iters = ctrl$g_mbo_iter * sum(getParamLengths(ps)))  # 2 times the parameter set size
  run = mbo(object, design = design, control = ctrlmbo, show.info = FALSE)
  ## in (function (fn, nvars, max = FALSE, pop.size = 1000, max.generations = 100,  : Stopped because hard maximum generation limit was hit.
  ## Genoud is a function that combines evolutionary search algorithms with derivative-based (Newton or quasi-Newton) methods to solve difficult optimization problems.
  ## not always occur: Warning in generateDesign(control$infill.opt.focussearch.points, ps.local,: generateDesign could only produce 20 points instead of 1000!
  ## in https://github.com/mlr-org/mlrMBO/issues/442, is being worked on https://github.com/mlr-org/mlrMBO/pull/444
  return(run)
}


# Mlr function: caculate performance of generated model given specific param_set
reinbo_mlr_fun = function(task, model, param_set, measure, cv_instance){
  lrn = genLearner.reinbo(task, model, param_set, measure)
  perf = resample(lrn, task, resampling = cv_instance, measures = measure, show.info = FALSE)$aggr
  return(perf)
}



# To get best model from mbo_cache of environment:
getBestModel = function(cache){
  models = keys(cache)
  results = data.frame(model = 0, y = 0)
  for (i in 1:length(models)) {
    results[i, 1] = models[i]
    results[i, 2] = max(cache[[models[i]]][, "y"])
  }
  key = results[results$y == max(results$y), "model"][1]
  ps = cache[[key]]
  ps = ps[(ps$y == max(ps$y)), (colnames(ps) != "epis_unimproved")][1, ]
  return(data.frame(Model = key, ps))
}

genLearnerForBestModel = function(task, best_model, measure){
  model = strsplit(as.character(best_model$Model), "\t")[[1]]
  param_set = as.list(best_model)
  param_set$Model = NULL
  param_set$y = NULL
  if (!is.null(param_set$C)) { param_set$C = 2^param_set$C }
  if (!is.null(param_set$sigma)) { param_set$sigma = 2^param_set$sigma }
  lrn = genLearner.reinbo(task, model, param_set, measure)
  return(lrn)
}


genLearner.reinbo = function(task, model, param_set, measure){
  p = getTaskNFeats(task)
  lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('%s', par.vals = ps.learner)",
                model[1], model[2], model[3])
  lrn = gsub(pattern = "perc", x = lrn, replacement = "perc = param_set$perc", fixed = TRUE)
  lrn = gsub(pattern = "rank", x = lrn, replacement = "rank = as.integer(max(1, round(p*param_set$rank)))", fixed = TRUE)
  lrn = gsub(pattern = "NA %>>%", x = lrn, replacement = "", fixed = TRUE)
  ps.learner = param_set
  ps.learner$perc = NULL
  ps.learner$rank = NULL
  if (model[3] == "classif.ranger") {
    p1 = p
    if (!is.null(param_set$perc)) {p1 = max(1, round(p*param_set$perc))}
    if (!is.null(param_set$rank)) {p1 = max(1, round(p*param_set$rank))}
    ps.learner$mtry = max(1, as.integer(p1*param_set$mtry))
  }
  lrn = eval(parse(text = lrn))
  return(lrn)
}
