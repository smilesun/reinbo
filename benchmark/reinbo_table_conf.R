source("reinbo_utils.R")
# A complete pipeline/model consists of 3 stages: 
# Preprocessing --> Feature filtering --> Classification

# Defult pipeline pool:
# Pre-processors: "Scale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()"
# Feature filters: "cpoFilterAnova()", "cpoFilterKruskal()", "cpoPca()", "cpoFilterUnivariate()"
# Classifiers: "classif.ksvm", "classif.ranger", "classif.kknn", "classif.xgboost", "classif.naiveBayes"

# "NA" indicates that no operator would be carried out at this stage.



# Use defaul pipeline pool:
custom_operators = list() 
# The pipeline search space could also be customized by setting, e.g.,
custom_operators = list(preprocess = c("cpoScale()", "NA"),
                        filter = c("cpoPca(center = FALSE, rank)", "cpoFilterAnova(perc)", "NA"),
                        classifier = c("classif.kknn", "classif.naiveBayes"))




## Parameters for RL environment:
g_operators = g_getOperatorList(custom_operators)
g_max_depth = length(g_operators)                  # stages: Scaling --> Feature filtering --> Classification
g_act_cnt = max(sapply(g_operators, length))       # max number of available operators at each stage 
g_state_names = g_genStateList(g_operators)
g_state_dim = length(g_state_names)              

## Parameters for BO_PROBE:
g_init_design = 4   # initial design size for MBO: g_init_design*sum(getParamLengths(par.set))
g_mbo_iter = 2      # iterations of MBO in each episode: g_mbo_iter*sum(getParamLengths(ps))
