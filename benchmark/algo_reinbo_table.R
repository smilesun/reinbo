algo_fun_reinbo_table = function(job, data, instance, measure, init_val = -1, conf4agent = NULL) {
  if (is.null(conf4agent)) {
    conf = rlR::getDefaultConf("AgentTable")
    if (init_val == -1) {
      conf$set(policy.maxEpsilon = 1, policy.minEpsilon = 0.01, policy.aneal.steps = 60)
    }
    conf4agent = conf
  }

  resample_opt_lock(
    instance$mlr_task_full,
    outer_loop_rins = instance$rins,
    func_opt = opt.reinbo.table,
    args_opt = list(budget = getGconf()$budget, init_val = init_val, conf = conf4agent),
    func_eval = lock_eval.reinbo.table,
    args_eval = list())
}
