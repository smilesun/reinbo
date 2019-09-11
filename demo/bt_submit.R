submitJobs(getJobPars()[algorithm != "reinbo_table", job.id, with = T])
ids_sk = getJobPars()[algorithm == "auto_sklearn", job.id, with = T] #  dont' run testJob for autosklearn since you can not easily kill it
submitJobs(ids_sk)
ids = getJobPars()[algorithm == "reinbo_table", job.id, with = T]
submitJobs(ids)
getJobPars()[(algorithm == "auto_sklearn") & (problem == "diabetes"), job.id, with = T]
getJobPars()[problem == "diabetes", job.id, with = T]
