rm(list = ls())
library(mlr)
library(mlrCPO)
library(reticulate)
library(BBmisc)
library(OpenML)
library(hash)
library(rlR)
library(mlrMBO)
library(phng)
library(R6)

source("reinbo_table_hyperpara_space.R")
source("reinbo_table_conf.R")
source("reinbo_table_env.R")
source("reinbo_table_func.R")
source("system.R")
source("bt_conf.R")

task = convertOMLTaskToMlr(getOMLTask(37))$mlr.task %>>% cpoDummyEncode(reference.cat = FALSE)
outer_loop = makeResampleInstance("CV", iters = 5, stratify = TRUE, task)

train_set = outer_loop$train.inds[[1]]
test_set = outer_loop$test.inds[[1]]

conf = rlR::getDefaultConf("AgentTable")
conf$set(policy.maxEpsilon = 1, policy.minEpsilon = 0.01, policy.aneal.steps = 60)
best_model = opt.reinbo.table(task, budget = 100L, measure = list(mmce), train_set = train_set, init_val = -1, conf = conf)
pred = lock_eval.reinbo.table(task, measure = list(mmce), train_set, test_set, best_model)
