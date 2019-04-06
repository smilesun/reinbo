# A complete pipeline/model consists of 3 stages: 
# Scaling --> Feature filtering --> Classification
# In each step there are 5 available operators as follows. 
# "NA" indicates that no operator would be carried out at this stage.



## Available operators:
g_operators = matrix(
  c("cpoScale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()", "NA",
    "cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoPca(center = FALSE, rank)", "cpoFilterUnivariate(perc)", "NA",
    "classif.ksvm", "classif.ranger", "classif.kknn", "classif.xgboost", "classif.naiveBayes"),
    ncol = 3)


## List of states in Q-table:
g_genStateList = function(g_operators) {
  state_list = c("s")
  for (step in 1:(ncol(g_operators)-1)){
    step_list = c()
    for (i in g_operators[, step]) {
      for (j in state_list) {
        if (length(strsplit(j, "[", fixed = TRUE)[[1]]) == step){
          step_list = c(step_list, paste0(j, "-[", i, "]"))
        }
      }
    }
    state_list = c(state_list, step_list)
  }
  return(state_list)
}


## Parameters for RL environment:
g_max_depth = ncol(g_operators)                   # stages: Scaling --> Feature filtering --> Classification
g_act_cnt = nrow(g_operators)                     # available operators at each stage 
g_state_names = g_genStateList(g_operators)
g_state_dim = length(g_state_names)              
# e.g. 
# s0: (  0 0 0 0 0   0 0 0 0 0   0 0 0 0 0  )
# s1: (  1 0 0 0 0   0 0 0 0 0   0 0 0 0 0  )  --> cpoScale()
# s2: (  1 0 0 0 0   0 1 0 0 0   0 0 1 0 0  )  --> cpoFilterKruskal()
# s3: (  1 0 0 0 0   0 1 0 0 0   0 0 1 0 0  )  --> classif.kknn
# => model = c("cpoScale()", "cpoFilterKruskal()", "classif.kknn")   



## Parameters for MBO iterations:
g_init_design = 4   # initial design size for MBO: g_init_design*sum(getParamLengths(par.set))
g_mbo_iter = 2      # iterations of MBO in each episode: g_mbo_iter*sum(getParamLengths(ps))



## List of all states:
  # g_genStateList = function(g_max_depth, g_act_cnt) {
  #   state_list = c("s")
  #   for (step in 1:(g_max_depth-1)) {
  #     step_list = c()
  #     for (i in 1:g_act_cnt) {
  #       for (j in state_list) {
  #         if (nchar(j) == step) {
  #           step_list = c(step_list, paste0(j, i))
  #         }
  #       }
  #     }
  #     state_list = c(state_list, step_list)
  #   }
  #   return(state_list)
  # }
  # 

## Get model at end of each episode:
g_getRLPipeline = function(last_state) {
  model = unlist(lapply(strsplit(last_state, "-")[[1]][-1], 
                function(x) {
                  x = gsub("[", x, replacement = "", fixed = TRUE)
                  gsub("]", x, replacement = "", fixed = TRUE)}))
  return(model)
}

get_act_names_perf_state = function() {
g_operators = matrix(
  c("cpoScale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()", "NA",
    "cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoPca(center = FALSE, rank)", "cpoFilterUnivariate(perc)", "NA",
    "classif.ksvm", "classif.ranger", "classif.kknn", "classif.xgboost", "classif.naiveBayes"),
  ncol = 3)
list = list("s" = g_operators[, 1])
for (i in sprintf("s%s", 1:5)) {
  text = sprintf("list$%s = g_operators[, 2]", i)
  eval(parse(text = text))
  for (j in sprintf(paste0(i, "%s"), 1:5)) {
    text = sprintf("list$%s = g_operators[, 3]", j)
    eval(parse(text = text))
  }
}
list
}


get_act_names_perf_state2 = function() {
g_operators = matrix(
  c("cpoScale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()", "NA",
    "cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoPca(center = FALSE, rank)", "cpoFilterUnivariate(perc)", "NA",
    "classif.ksvm", "classif.ranger", "classif.kknn", "classif.xgboost", "classif.naiveBayes"),
  ncol = 3)


list = list("s" = g_operators[, 1])

step1_states = sprintf("s-[%s]", g_operators[, 1])

for (i in step1_states) {
  text = sprintf("list$'%s' =  g_operators[, 2]",  i)
  eval(parse(text = text))
  for (j in sprintf("%s-[%s]", i,  g_operators[, 2])) {
    text = sprintf("list$'%s' =  g_operators[, 3]",  j)
    eval(parse(text = text))
  }
}
list
}
