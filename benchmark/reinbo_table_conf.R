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


# Get list of operators:
g_getOperatorList = function(custom_operators) {
  default_operators = list(
    preprocess = c("cpoScale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()", "NA"),
    filter = c("cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoPca(center = FALSE, rank)", "cpoFilterUnivariate(perc)", "NA"),
    classifier = c("classif.ksvm", "classif.ranger", "classif.kknn", "classif.xgboost", "classif.naiveBayes"))
  for (stage in names(default_operators)){
    if (!is.null(custom_operators[[stage]])) {
      default_operators[stage] = custom_operators[stage]
    }
  }
  return(default_operators)
}


# Generate list of all potential states in Q table:
g_genStateList = function(operators) {
  state_list = c("s")
  last_stage = state_list
  for (stage in c("preprocess", "filter")){
    current_stage = c()
    for (i in last_stage){
      for (j in operators[stage]){
        current_stage = c(current_stage, paste0(i, "-[", j, "]"))
      }
    }
    state_list = c(state_list, current_stage)
    last_stage = current_stage
  }
  return(state_list)
}


# Get list of all potential actions at each state:
get_act_names_perf_state = function(g_operators){
  list = list("s" = g_operators$preprocess)
  step1_states = sprintf("s-[%s]", g_operators$preprocess)
  for (i in step1_states) {
    text = sprintf("list$'%s' =  g_operators$filter",  i)
    eval(parse(text = text))
    for (j in sprintf("%s-[%s]", i,  g_operators$filter)) {
      text = sprintf("list$'%s' =  g_operators$classifier",  j)
      eval(parse(text = text))
    }
  }
  return(list)
}


## Parameters for RL environment:
g_operators = g_getOperatorList(custom_operators)
g_max_depth = length(g_operators)                  # stages: Scaling --> Feature filtering --> Classification
g_act_cnt = max(sapply(g_operators, length))       # max number of available operators at each stage 
g_state_names = g_genStateList(g_operators)
g_state_dim = length(g_state_names)              

## Parameters for BO_PROBE:
g_init_design = 4   # initial design size for MBO: g_init_design*sum(getParamLengths(par.set))
g_mbo_iter = 2      # iterations of MBO in each episode: g_mbo_iter*sum(getParamLengths(ps))


# Get model at end of each episode:
g_getRLPipeline = function(last_state) {
  model = unlist(lapply(strsplit(last_state, "-")[[1]][-1],
                function(x) {
                  x = gsub("[", x, replacement = "", fixed = TRUE)
                  gsub("]", x, replacement = "", fixed = TRUE)}))
  return(model)
}
