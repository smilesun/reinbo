algo_fun_auto_sklearn = function(job, data, instance, measure = list(mmce), flag_light) {
  resample_opt_lock(instance$mlr_task_full,
    outer_loop_rins = instance$rins,
    func_opt = opt.auto.sklearn,
    args_opt = list(budget = getGconf()$budget, job_id = job$job.id, flag_light = flag_light),
    func_eval = lock_eval.auto.sklearn,
    args_eval = list())
}
