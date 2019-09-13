makeRLearner.classif.autosklearn = function() {
  makeRLearnerClassif(
    cl = "classif.autosklearn",
    package = "reticulate",
    # For full paramset see https://automl.github.io/auto-sklearn/master/api.html
    # Attention: Defaults are not exactly as in  autosklearn
    par.set = makeParamSet(
      makeIntegerLearnerParam("time_left_for_this_task", lower = 1L, upper = Inf, default = 3600L),
      makeIntegerLearnerParam("per_run_time_limit", lower = 1L, upper = Inf, default = 360L),
      makeIntegerLearnerParam("initial_configurations_via_metalearning", lower = 0L, upper = Inf, default = 25L),
      makeUntypedLearnerParam("include_estimators", default = NULL, special.vals = list(NULL)),
      makeUntypedLearnerParam("include_preprocessors", default = NULL, special.vals = list(NULL)),
      makeUntypedLearnerParam("exclude_estimators", default = NULL, special.vals = list(NULL)),
      makeUntypedLearnerParam("exclude_preprocessors", default = NULL, special.vals = list(NULL)),
      makeIntegerLearnerParam("ensemble_size", lower = 0L, upper = Inf, default = 0L),
      makeIntegerLearnerParam("ensemble_nbest", lower = 0L, upper = Inf, default = 50L),
      makeLogicalLearnerParam("delete_tmp_folder_after_terminate", default = FALSE),
      makeLogicalLearnerParam("delete_output_folder_after_terminate", default = FALSE),
      makeLogicalLearnerParam("shared_mode", default = FALSE),
      makeUntypedLearnerParam("tmp_folder", default = NULL, special.vals = list(NULL)),
      makeUntypedLearnerParam("output_folder", default = NULL, special.vals = list(NULL)),
      makeIntegerLearnerParam("runcount_limit", lower = 1L, upper = 10L, default = 5L),
      makeUntypedLearnerParam("smac_scenario_args", default = NULL, special.vals = list(NULL)),
      makeDiscreteLearnerParam("resampling_strategy", default = "cv", values = c("cv", "partial-cv", "holdout-iterative-fit", "holdout")),
      makeUntypedLearnerParam("resampling_strategy_arguments", default = NULL, special.vals = list(NULL))
    ),
    properties = c("twoclass", "multiclass", "numerics", "prob", "missings", "factors"),
    name = "Autosklearn",
    short.name = "autosklearn",
    note = "Defaults deviate from autosklearn defaults"
  )
}


trainLearner.classif.autosklearn = function(.learner, .task, .subset, .weights = NULL, ...) {
  
  autosklearn = import("autosklearn")
  classifier = autosklearn$classification$AutoSklearnClassifier(...)
  
  train = getTaskData(.task, .subset, target.extra = TRUE)
  feat.type = ifelse(vlapply(train$data, is.factor), "Categorical", "Numerical")
  
  classifier$fit(as.matrix(train$data), train$target, feat_type = feat.type)
  classifier$fit_ensemble(train$target, ensemble_size = 1)
  classifier$refit(as.matrix(train$data), train$target)    ## Refit for cv method
  return(classifier)
}

predictLearner.classif.autosklearn = function(.learner, .model, .newdata, ...) {
  as.factor(.model$learner.model$predict(as.matrix(.newdata)))
}



# Auto-sklearn algorithm:
opt.auto.sklearn = function(task, budget, measure, job_id, train_set, flag_light) {
  # job_id used for folder name
  #randstr = stringi::stri_replace(toString(rnorm(1)), replacement = "", regex ="\\.")
  if(flag_light) {
    g_classifiers = list("random_forest", "k_nearest_neighbors", "libsvm_svc", "xgradient_boosting", "multinomial_nb")                                                                                     
  #g_preprocess = list("pca", "no_preprocessing", "select_percentile_classification", "normalize", "standardize", "none", "minmax", "variance_threshold") data preprocessing methods does not work
    g_preprocess = list("pca", "no_preprocessing", "select_percentile_classification")
  }
  else {
    g_classifiers = NULL
    g_preprocess = NULL
  }

  automl = makeLearner("classif.autosklearn",
                       time_left_for_this_task = 100000L,
                       per_run_time_limit = 25L,
                       ensemble_size = 0,
                       initial_configurations_via_metalearning = 0L,
                       resampling_strategy = "cv",
                       include_preprocessors = g_preprocess,
                       include_estimators = g_classifiers,
                       # default tmp_folder name will cause no space left error
                       tmp_folder = paste0("../autosklearn_tmp/autosklearn_tmp", job_id),  # it makes more sense touse seperate folder since different job_id are different problems 
                       output_folder = paste0("../autosklearn_tmp/autosklearn_out", job_id),
                       delete_tmp_folder_after_terminate = FALSE,  # to use together with shared_mode = T
                       #task 2 failed - \"FileExistsError: [Errno 17] File exists: '../autosklearn_tmp/autosklearn_tmp1'
                       #delete_tmp_folder_after_terminate=T,  ## will cause error file exist
                       delete_output_folder_after_terminate = FALSE,
                       #delete_output_folder_after_terminate=T,
                       shared_mode = TRUE,
                       resampling_strategy_arguments = list(folds = getGconf()$NCVInnerIter),
                       smac_scenario_args = list(runcount_limit = budget)
  )
  mmodel = train(automl, task, subset = train_set)
  return(mmodel)
}

# Predict performance of the best model on test/lock dataset:
lock_eval.auto.sklearn = function(task, measure, train_set = NULL, test_set, best_model) {
  prediction = predict(best_model, task, subset = test_set)
  mpred = performance(prediction, measures = measure)
  return(mpred)
}

