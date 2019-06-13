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

run = function(cs, budget = 1000) {
  hh = reticulate::import("python_smac_space")
  budget = 1000
  scenario = Scenario({"run_obj": "quality",   # we optimize quality (alternatively runtime)
                     "runcount-limit": budget,  # maximum function evaluations
                     "cs": cs,               # configuration space
                     "deterministic": "true"
                     })
  print("Optimizing! Depending on your machine, this might take a few minutes.")
  smac = SMAC(scenario=scenario, rng=np.random.RandomState(42), tae_runner=objective)
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
objective = function(cfg) {
  # some variables are defined in the scope where this function is called
  model_index <<- model_index + 1
  model_list[[model_index]] <<- cfg
  lrn = gen_mlrCPOPipe_from_smac_cfg(cfg)
  perf = resample(lrn, subTask, resampling = inner_loop, measures = measure, show.info = FALSE)$aggr
  perf_list <<- c(perf_list, as.numeric(perf))
  return(perf)
}

test_gen_mlrCPOPipe_from_smac_cfg = function() {
  subTask = mlr::iris.task
  cfg = reticulate::import("python_smac_space")
  cfg = cfg$stub
  gen_mlrCPOPipe_from_smac_cfg(cfg)
}

gen_mlrCPOPipe_from_smac_cfg = function(cfg) {
    #cfg = cfg.sample_configuration()
    # convert ConfigSpace.configuration_space.ConfigurationSpace to ConfigSpace.configuration_space.Configuration
    # For deactivated parameters, the configuration stores None-values. so we remove them.
    #cfg = list(Model = "xgboost", Preprocess = "cpoScale(center = FALSE)", FeatureFilter = "cpoPca(center = FALSE, rank = rank_val)", lrn_xgboost_max_depth = 3, lrn_xgboost_eta = 0.03, fe_pca_rank = 0.5) # for testing and debug
    model = cfg$Model
    preprocess = cfg$Preprocess
    pfilter = cfg$FeatureFilter
    perc_val = NULL
    rank_val = NULL

    ##
    extract_hyper_prefix = function(prefix = "lrn", cfg) {
      names4lrn_hyp = grep(pattern = prefix, x = names(cfg), value = T)
      ps.learner = cfg[names4lrn_hyp]  # evaluted later by R function eval
      pattern = paste0("(", prefix, "_[:alpha:]+_)*")
      #ns4hyper = gsub(pattern = pattern, x = names4lrn_hyp, replacement="", ignore.case = T)
      ns4hyper = stringr::str_replace(string = names4lrn_hyp, pattern = pattern, replacement="")
      names(ps.learner) = ns4hyper
      ps.learner
    }
    ##
    ps.learner  =  extract_hyper_prefix("lrn", cfg)  # hyper-parameters for learner must exist

    names4Fe = grep(pattern = "fe", x = names(cfg), value = T)

    p = mlr::getTaskNFeats(subTask)  # this subTask relies on global variable

    if(length(names4Fe) > 0) {
      ps.Fe = extract_hyper_prefix("fe", cfg)
      if(grepl(pattern = "perc", x = names(ps.Fe)))  {
        name4featureEng_perc = grep(pattern = "perc", x = names(ps.Fe), value = T)
        perc_val = ps.Fe[[name4featureEng_perc]] 
      }
      if(grepl(pattern = "rank", x = names(ps.Fe))) {
        name4featureEng_rank = grep(pattern = "rank", x = names(ps.Fe), value = T)
        rank_val = ceiling(ps.Fe[[name4featureEng_rank]] * p)
      }
    }

    lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('classif.%s', par.vals = ps.learner)",
                preprocess, pfilter, model)
    lrn = gsub(pattern = "NA %>>%", x = lrn, replacement = "", fixed = TRUE)

 
    # set mtry after reducing the number of dimensions
    if (model == "ranger") {
        p1 = p
        if (!is.null(perc_val)) {p1 = max(1, round(p*perc_val))}
        if (!is.null(rank_val)) {p1 = rank_val}
        ps.learner$mtry = max(1, as.integer(p1*ps.learner$mtry))
    }
    lrn = paste0("library(mlrCPO);library(magrittr);", lrn)
    obj_lrn = eval(parse(text = lrn))
    return(obj_lrn)
}
