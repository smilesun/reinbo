# SMAC algorithm:
opt.tpe = function(task, budget, measure, train_set = NULL) {
  subTask <<- task
  if (!is.null(train_set)) subTask <<- subsetTask(task, train_set)
  inner_loop <<- makeResampleInstance("CV", iters = getGconf()$NCVInnerIter, stratify = TRUE, subTask)
  source_python("python_smac_space.py")
  hp = import("hyperopt")
  model_index <<- 0
  model_list <<- list()
  perf_list <<- NULL
  measure <<- measure
  best = hp$fmin(objective, space = space, algo = hp$tpe$suggest, max_evals = budget)
  best_model_index = which(perf_list == min(perf_list))[1]
  mmodel = model_list[[best_model_index]]
  return(mmodel)
}

run = function(cs) {
scenario = Scenario({"run_obj": "quality",   # we optimize quality (alternatively runtime)
                     "runcount-limit": 1000,  # maximum function evaluations
                     "cs": cs,               # configuration space
                     "deterministic": "true"
                     })
print("Optimizing! Depending on your machine, this might take a few minutes.")
smac = SMAC(scenario=scenario, rng=np.random.RandomState(42), tae_runner=svm_from_cfg)
incumbent = smac.optimize()
inc_value = svm_from_cfg(incumbent)
print("Optimized Value: %.2f" % (inc_value))
}

# Predict function: evaluate best model on test dataset
lock_eval.tpe = function(task, measure, train_set, test_set, best_model){
  lrn = genLearner.tpe(best_model)
  mod = train(lrn, task, subset = train_set)
  pred = predict(mod, task, subset = test_set)
  mpred = performance(pred, measures = measure)
  return(mpred)
}


# Objective to optimize:
objective = function(args) {
  model_index <<- model_index + 1
  model_list[[model_index]] <<- args
  lrn = genLearner.tpe(args)
  perf = resample(lrn, subTask, resampling = inner_loop, measures = measure, show.info = FALSE)$aggr
  perf_list <<- c(perf_list, as.numeric(perf))
  return(perf)
}
# one sample of args: args = hp$pyll$stochastic$sample(py$space)


# Generate mlr learner for configuration:
genLearner.tpe = function(args){
  model = args$Classifier$model
  args$Classifier$model = NULL
  ps.learner = args$Classifier    
  filter = args$FeatureFilter$filter
  lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('classif.%s', par.vals = ps.learner)", 
                args$Preprocess, filter, model)
  lrn = gsub(pattern = "NA %>>%", x = lrn, replacement = "", fixed = TRUE)
  lrn = gsub(pattern = "perc", x = lrn, replacement = "perc = args$FeatureFilter$perc", fixed = TRUE)
  p = getTaskNFeats(subTask)
  lrn = gsub(pattern = "rank", x = lrn, replacement = "rank = as.integer(max(1, round(p*args$FeatureFilter$rank)))", fixed = TRUE)
  if (model == "ranger") {
    p1 = p
    if (!is.null(args$FeatureFilter$perc)) {p1 = max(1, round(p*args$FeatureFilter$perc))}
    if (!is.null(args$FeatureFilter$rank)) {p1 = max(1, round(p*args$FeatureFilter$rank))}
    ps.learner$mtry = max(1, as.integer(p1*args$FeatureFilter$mtry))
  }
  lrn = eval(parse(text = lrn))
  return(lrn)
}


gen_mlrCPOPipe_from_smac_cfg = function(cfg, subtask) {
    #cfg = cfg.sample_configuration()
    # convert ConfigSpace.configuration_space.ConfigurationSpace to ConfigSpace.configuration_space.Configuration
    # For deactivated parameters, the configuration stores None-values. so we remove them.
    #cfg = {k : cfg[k] for k in cfg if cfg[k]}
    cfg = list(Model = "xgboost", Preprocess = "NA", FeatureFilter = "NA", lrn_xgboost_depth = 3)
    model = cfg$Model
    preprocess = cfg$Preprocess
    pfilter = cfg$FeatureFilter
    #+name4 = grep(pattern = "fe", x = c("fe_cps", "agsg", "cag"), value = T)
    name4featureEng_perc = grep(pattern = "perc", x = names(cfg), value = T)
    name4lrn_hyp = grep(pattern = "lrn", x = names(cfg), value = T)
    ps.learner = cfg[name4lrn_hyp]  # evaluted later by R function eval
    ns4hyper = names(ps.learner) 
    ns4hyper = gsub("(lrn_[a-z]+_)*", x = ns4hyper, replacement="")
    names(ps.learner) = ns4hyper
    lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('classif.%s', par.vals = ps.learner)",
                preprocess, pfilter, model)
    lrn = gsub(pattern = "NA %>>%", x = lrn, replacement = "", fixed = TRUE)
    #names(cfg)

    if(length(name4featureEng_perc) > 0)  {
      perc_val = cfg[[name4featureEng_perc]]
      lrn = gsub(pattern = "perc", x = lrn, replacement = "perc = perc_val", fixed = TRUE)
    }

    p = getTaskNFeats(subTask)
    lrn = gsub(pattern = "rank", x = lrn, replacement = "rank = as.integer(max(1, round(p*pca_rank)))", fixed = TRUE)
    if (model == "ranger") {
        p1 = p
        if (!is.null(args$FeatureFilter$perc)) {p1 = max(1, round(p*args$FeatureFilter$perc))}
        if (!is.null(args$FeatureFilter$rank)) {p1 = max(1, round(p*args$FeatureFilter$rank))}
        ps.learner$mtry = max(1, as.integer(p1*args$FeatureFilter$mtry))
    }
    lrn = eval(parse(text = lrn))
    return(lrn)
}
