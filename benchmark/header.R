options(mlr.show.info = FALSE)
library(batchtools)
tosources = c("bt_conf.R", "utility.R")

depend_reinbo_table = c("algo_reinbo_table.R", "reinbo_table_func.R", "reinbo_table_env.R", "reinbo_table_conf.R", "reinbo_table_hyperpara_space.R")
tosources = c(tosources, depend_reinbo_table)

depend_auto_sklearn = c("algo_auto_sklearn.R", "auto_sklearn_func.R")
tosources = c(tosources, depend_auto_sklearn)

depend_tpot = c("algo_tpot.R", "tpot_func.R")
tosources = c(tosources, depend_tpot)

depend_random_search = c("algo_random_search.R", "random_search_func.R", "random_search_space.R")
tosources = c(tosources, depend_random_search)

depend_tpe = c("algo_tpe.R", "tpe_func.R")
tosources = c(tosources, depend_tpe)

depend_irace = c("algo_irace.R", "irace_func.R")
tosources = c(tosources, depend_irace)


pkgs = c("reticulate", "mlr", "mlrCPO", "OpenML", "parallelMap", "phng", "rlR", "hash", "mlrMBO", "R6", "foreach", "rlist", "magrittr", "irace")