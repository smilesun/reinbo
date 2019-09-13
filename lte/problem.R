tasks = lapply(task_ids, getOMLTask)
tasks = lapply(tasks, convertOMLTaskToMlr)

prob_fun = function(data, job) {
  mlr_task_full = data %>>% cpoDummyEncode(reference.cat = FALSE)
  outer_iters = getGconf()$NCVOuterIter
  outer_loop_rins = makeResampleInstance("CV", iters = outer_iters, stratify = TRUE, mlr_task_full)
  list(rins = outer_loop_rins, mlr_task_full = mlr_task_full)
}

for (task in tasks)
  addProblem(name = getTaskId(task$mlr.task), data = task$mlr.task, fun = prob_fun, seed = getGconf()$prob_seed)
