flag_debug = F
task_ids = 37
if (!flag_debug) task_ids = c(14, 23, 37, 53, 3917, 9946, 9952, 9978, 125921, 146817, 146820)
getGconf = function() {
  conf_common =  list(
      NCVOuterIter = 5L,
      NCVInnerIter = 5L,
      measures = list(mlr::mmce),
      repl = 10L,
      prob_seed = 1L,
      RLMaxEpisode = 2000L # this number does not play a role, it only ensures RL could run for sufficient time
      )

  conf_debug =  list(
      budget = 40L,
      conf_tpot = list(generations = 1L, population_size = 3L, offspring_size = 3L, config_dict = 'TPOT light')
      )

  conf_full =  list(
      budget = 1000L,
      # TPOT will evaluate population_size + generations × offspring_size pipelines in total.
      conf_tpot = list(generations = 20L, population_size = 10L, offspring_size = 50L)
      )
  if (flag_debug) return(c(conf_debug, conf_common))
  return(c(conf_full, conf_common))
}

resources_light = list(
  walltime = 60L*60*8,  
  memory = 1024L*2,
  ntasks = 1L,
  ncpus = 1L,
  nodes = 1L,
  clusters = "serial")

resources_bigmem = list(
  walltime = 60L*60*8,  
  memory = 1024L*4,
  ntasks = 1L,
  ncpus = 1L,
  nodes = 1L,
  clusters = "serial")



resources = list(
  walltime = 60L*60*12,  
  memory = 1024L*2,
  ntasks = 1L,
  ncpus = 1L,
  nodes = 1L,
  clusters = "serial")
