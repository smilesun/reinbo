rm(list = ls())
library(mlr)
library(mlrCPO)
library(reticulate)
library(BBmisc)
library(OpenML)
use_condaenv("w_env")
source("auto-sklearn_fun.R")

g_classifiers = list("random_forest", "k_nearest_neighbors", "libsvm_svc", "xgradient_boosting", "multinomial_nb")
g_preprocess = list("pca", "no_preprocessing", "select_percentile_classification")



task = convertOMLTaskToMlr(getOMLTask(3))$mlr.task %>>% cpoDummyEncode(reference.cat = FALSE)
#head(getTaskData(task, target.extra = TRUE)$target)
set.seed(1)
outer_loop_CV5 = makeResampleInstance("CV", iters = 5, task = task)

train_set = outer_loop_CV5$train.inds[[1]]
test_set = outer_loop_CV5$test.inds[[1]]
train_data = getTaskData(task, train_set, target.extra = TRUE)
test_data = getTaskData(task, test_set, target.extra = TRUE)

set.seed(1)
automl = makeLearner("classif.autosklearn",
                     time_left_for_this_task = 1000000L,
                     per_run_time_limit = 25L,
                     ensemble_size = 0,
                     #include_preprocessors = g_preprocess,
                     #include_estimators = g_classifiers,
                     initial_configurations_via_metalearning = 0L,
                     resampling_strategy = "cv",
                     resampling_strategy_arguments = list(folds = 5L),
                     smac_scenario_args = list(runcount_limit = 5L)
)

a = Sys.time()
mod = train(automl, task, subset = train_set)
prediction = predict(mod, task, subset = test_set)
pred = performance(prediction)
print(Sys.time() - a)





# autosklearn = import("autosklearn")
# sklearn = import("sklearn")
# automl = autosklearn$classification$AutoSklearnClassifier(
#   time_left_for_this_task = 1000L,
#   per_run_time_limit = 200L,
#   ensemble_size = 0,
#   # include_preprocessors = g_preprocess,
#   # include_estimators = g_classifiers,
#   initial_configurations_via_metalearning = 0L,
#   resampling_strategy = "cv",
#   resampling_strategy_arguments = list(folds = 5L),
#   smac_scenario_args = dict(runcount_limit = 5L))


# automl$fit(train_data$data, train_data$target, metric=autosklearn$metrics$accuracy)
# automl$fit_ensemble(train_data$target, ensemble_size = 1)
# automl$refit(train_data$data, train_data$target)
# predictions = automl$predict(test_data$data)
# pred = sklearn$metrics$accuracy_score(test_data$target, predictions)




