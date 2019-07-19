# mlrMBO algorithm:
opt.mlrmbo = function(task, budget, measure, train_set = NULL) {
  subTask = task
  if (!is.null(train_set)) subTask = subsetTask(task, train_set)
  inner_loop = makeResampleInstance("CV", iters = getGconf()$NCVInnerIter, stratify = TRUE, subTask)
  run = mlrMBO_func(subTask, instance = inner_loop, measure, budget)
  mmodel = run$x
  return(mmodel)
}


# Predict function: evaluate best model on test dataset
lock_eval.mlrmbo = function(task, measure, train_set, test_set, best_model){
  best_model$sigma = 2^(best_model$sigma)
  best_model$C = 2^(best_model$C)
  lrn = genLearner.mbo(task, best_model)
  mod = train(lrn, task, subset = train_set)
  pred = predict(mod, task, subset = test_set)
  perf = performance(pred, measures = measure)
  return(perf)
}


# hyper-parameter space
par.set = makeParamSet(
  makeDiscreteParam('Pre', values = c("cpoScale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()", "no_operator")),
  makeDiscreteParam('Filter', values = c("cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoPca(center = FALSE, rank)", "cpoFilterUnivariate(perc)", "no_operator")),
  makeNumericParam('perc', lower = .1, upper = 1, requires = quote(Filter %in% c("cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoFilterUnivariate(perc)"))),
  makeNumericParam('rank', lower = .1, upper = 1, requires = quote(Filter == "cpoPca(center = FALSE, rank)")),
  makeDiscreteParam('Learner', values = c("kknn", "ksvm", "xgboost", "ranger", "naiveBayes")),
  makeIntegerParam('k', lower = 1L, upper = 20L, requires = quote(Learner == "kknn")),
  makeNumericParam("C", lower = -15, upper = 15, trafo = function(x) 2^x, requires = quote(Learner == 'ksvm')),
  makeNumericParam("sigma", lower = -15, upper = 15, trafo = function(x) 2^x, requires = quote(Learner == 'ksvm')),
  makeNumericParam("mtry", lower = 1/10, upper = 1/1.5, requires = quote(Learner == 'ranger')),
  makeNumericParam("sample.fraction", lower = .1, upper = 1, requires = quote(Learner == 'ranger')),
  makeNumericParam("eta", lower = .001, upper = .3, requires = quote(Learner == 'xgboost')),
  makeIntegerParam("max_depth", lower = 1L, upper = 15L, requires = quote(Learner == 'xgboost')),
  makeNumericParam("subsample", lower = .5, upper = 1, requires = quote(Learner == 'xgboost')),
  makeNumericParam("colsample_bytree", lower = .5, upper = 1, requires = quote(Learner == 'xgboost')),
  makeNumericParam("min_child_weight", lower = 0, upper = 50, requires = quote(Learner == 'xgboost')),
  makeNumericParam("laplace", lower = .01, upper = 100, requires = quote(Learner == 'naiveBayes'))
)


# generate learner for task and specific parameter set
genLearner.mbo <- function(task, param_set){
  p = getTaskNFeats(task)
  lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('classif.%s', par.vals = ps.learner)", 
                param_set$Pre, param_set$Filter, param_set$Learner)
  lrn = gsub(pattern = "perc", x = lrn, replacement = "perc = param_set$perc", fixed = TRUE)
  lrn = gsub(pattern = "rank", x = lrn, replacement = "rank = as.integer(max(1, round(p*param_set$rank)))", fixed = TRUE)
  lrn = gsub(pattern = "no_operator %>>%", x = lrn, replacement = "", fixed = TRUE)
  ps.learner = param_set
  ps.learner$perc = NULL
  ps.learner$rank = NULL
  ps.learner$Pre = NULL
  ps.learner$Filter = NULL
  ps.learner$Learner = NULL
  ps.learner[is.na(ps.learner)] = NULL
  if (param_set$Learner == "ranger") {
    p1 = p
    if (!is.na(param_set$perc)) {p1 = max(1, round(p*param_set$perc))}
    if (!is.na(param_set$rank)) {p1 = max(1, round(p*param_set$rank))}
    ps.learner$mtry = max(1, as.integer(p1*param_set$mtry))
  }
  lrn = eval(parse(text = lrn))
  return(lrn)
}


# using mlrMBO to optimize pipeline
mlrMBO_func <- function(task, instance, measure, budget){
  objfun = makeSingleObjectiveFunction(
    fn = function(x) {
      lrn = genLearner.mbo(task, x)
      perf = resample(lrn, task, resampling = instance, measures = measure, show.info = FALSE)$aggr
      return(perf)
    },
    par.set = par.set,
    has.simple.signature = FALSE,
    minimize = TRUE
  )
  ctrl = setMBOControlTermination(makeMBOControl(), iters = budget-4*length(par.set$pars)) 
  run = mbo(objfun, control = ctrl, show.info = FALSE)
  return(run)
}




# Test:
# measure = list(mmce)
# task = sonar.task
# inner_loop = makeResampleInstance("CV", iters = 3, stratify = TRUE, task)
# outer_loop_rins = makeResampleInstance("CV", iters = 5, stratify = TRUE, task)
# opt_set = outer_loop_rins$train.inds[[1]]
# lock_set = outer_loop_rins$test.inds[[1]]
# mmodel = opt.mlrmbo(task, 66, measure)
# perf = lock_eval.mlrmbo(task, measure, opt_set, lock_set, mmodel)



