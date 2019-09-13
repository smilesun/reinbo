algo_fun_random_search = function(job, data, instance, measure = list(mmce)) {
  resample_opt_lock(
    instance$mlr_task_full,
    outer_loop_rins = instance$rins,
    func_opt = opt.random.search,
    args_opt = list(budget = getGconf()$budget),
    func_eval = lock_eval.random.search,
    args_eval = list())
}