algo_fun_tpe = function(job, data, instance, measure = list(mmce)) {
  resample_opt_lock(
    instance$mlr_task_full,
    outer_loop_rins = instance$rins,
    func_opt = opt.tpe,
    args_opt = list(budget = getGconf()$budget),
    func_eval = lock_eval.tpe,
    args_eval = list())
}
