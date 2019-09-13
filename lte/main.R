rm(list = ls())
source("system.R")
source("header.R")
Reg_name =  "reg"
datestr = stringi::stri_replace_all(Sys.Date(), regex = "-", replacement="_") ## use date as registry name
strhour = stringi::stri_replace_all(format(Sys.time(), "%H-%M"), regex = "-", replacement = "_")
#unlink("reg_table_1", recursive = TRUE)  dangerous !!
reg_dir = paste0(Reg_name, datestr, "__", strhour)
reg = makeExperimentRegistry(file.dir = reg_dir, conf.file = mconf.file,
                             packages = pkgs,
                             source = tosources)
if (flag_local) reg$cluster.functions = makeClusterFunctionsMulticore(ncpus = 60L)  # run on my own workstation
source("problem.R")
# opt = function(task, budget, measure, train_set, ...) {
#   UseMethod("opt", task, budget, measure, train_set)
# }
#
# lock_eval = function(task, measure, train_set, test_set, best_model, ...) {
#   UseMethod("lock_eval", task, measure, train_set, test_set, best_model)
# }
#

algo.designs = list()

algoname = "reinbo_table"
addAlgorithm(name = algoname, fun = algo_fun_reinbo_table)
algo.designs[[algoname]] = data.frame()

algoname = "auto_sklearn"
addAlgorithm(name = algoname, fun = algo_fun_auto_sklearn)
algo.designs[[algoname]] = data.frame(flag_light = T)

algoname = "tpot"
addAlgorithm(name = algoname, fun = algo_fun_tpot)
algo.designs[[algoname]] = data.frame()


algoname = "random_search"
addAlgorithm(name = algoname, fun = algo_fun_random_search)
algo.designs[[algoname]] = data.frame()

algoname = "tpe"
addAlgorithm(name = algoname, fun = algo_fun_tpe)
algo.designs[[algoname]] = data.frame()

algoname = "irace"
addAlgorithm(name = algoname, fun = algo_fun_irace)
algo.designs[[algoname]] = data.frame()


source("algo_reinbo_table.R")
source("algo_auto_sklearn.R")
source("algo_tpot.R")
source("algo_random_search.R")
source("algo_tpe.R")
source("algo_irace.R")

addExperiments(algo.designs = algo.designs, repls = getGconf()$repl)
summarizeExperiments()
