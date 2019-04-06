tb = getJobPars(findDone())
getJobPars(findQueued())
getJobPars(findSubmitted())
unique(tb[, "problem"])
ids = tb[(algorithm == "reinbo_table") & (problem == "LED-display-domain-7digit"), job.id, with = T]
ids = tb[(algorithm == "reinbo_table") & (problem == "wdbc"), job.id, with = T]
ids = findDone()
reslist = reduceResultsList(ids = ids, fun = function(job, res) {
  res2 = list()
  res2$prob.name = job$prob.name
  res2$algo.name = job$algo.name
  res2$job.id = job$job.id
  res2$repl = job$repl
  res2$mmce = mean(res$vec_mpred)
  #res2$model = res$list_mmodel
  res2
})
dt_res = rbindlist(reslist)
saveRDS(dt_res, file = "reinbo_new_cut_episode.rds")
