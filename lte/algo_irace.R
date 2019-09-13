library(irace)
algo_fun_irace = function(job, data, instance, measure = list(mmce)) {
  resample_opt_lock(
    instance$mlr_task_full,
    outer_loop_rins = instance$rins,
    func_opt = opt.irace,
    args_opt = list(budget = getGconf()$budget),
    func_eval = lock_eval.irace,
    args_eval = list())
}