# Hello, world!
#
# This is an example function named 'hello' 
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

hello <- function() {
  print("Hello, world!")
}

getGconf = function() {
  flag_debug = T
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
