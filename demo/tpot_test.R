rm(list = ls())
library(mlr)
library(mlrCPO)
library(reticulate)
library(BBmisc)
library(OpenML)
source("system.R")

set.seed(1)
task = convertOMLTaskToMlr(getOMLTask(37))$mlr.task %>>% cpoDummyEncode(reference.cat = FALSE)
outer_loop_CV5 = makeResampleInstance("CV", iters = 5, task = task)
train_set = outer_loop_CV5$train.inds[[1]]
test_set = outer_loop_CV5$test.inds[[1]]
train_data = getTaskData(task, train_set, target.extra = TRUE)
test_data = getTaskData(task, test_set, target.extra = TRUE)

tpot = import("tpot")
pipeline_optimizer = tpot$TPOTClassifier(generations = 2L, population_size = 3L,
                                         offspring_size = 3L, cv = 5L, 
                                         config_dict = 'TPOT light')

pipeline_optimizer$fit(train_data$data, as.numeric(train_data$target))
pred = 1 - pipeline_optimizer$score(test_data$data, as.numeric(test_data$target))




