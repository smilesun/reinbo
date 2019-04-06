library(batchtools)
source("system.R")
reg = loadRegistry("reg_test", writeable = T, work.dir = getwd())
refun = function(job, res) {
  cv5 = mean(res$vec_mpred)
  list(cv5 = cv5)
}

res = reduceResultsDataTable(ids = findDone(), fun = refun)
unwrap(res, sep = ".")
