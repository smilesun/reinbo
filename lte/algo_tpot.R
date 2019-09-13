algo_fun_tpot = function(job, data, instance, measure = list(mmce)) {
  resample_opt_lock(instance$mlr_task_full,
    outer_loop_rins = instance$rins,
    func_opt = opt.tpot,
    args_opt = list(budget = getGconf()$budget),
    func_eval = lock_eval.tpot,
    args_eval = list())
}
