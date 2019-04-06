resample_opt_lock = function(mlr_task_full, outer_loop_rins, func_opt, func_eval, args_opt = list(), args_eval = list()) {
  outer_iters = getGconf()$NCVOuterIter
  measure = getGconf()$measures
  list_lock = foreach(outer_iter = 1:outer_iters) %do% {
    opt_set = outer_loop_rins$train.inds[[outer_iter]]
    lock_set = outer_loop_rins$test.inds[[outer_iter]]
    mmodel = do.call(func_opt, args = c(list(task = mlr_task_full, train_set = opt_set, measure = measure), args_opt))
    mpred = do.call(func_eval, args = c(list(task = mlr_task_full, train_set = opt_set, test_set = lock_set, measure = measure, best_model = mmodel), args_eval))
    return(list(mmodel = mmodel, mpred = mpred))
  }
  list_mmodel = rlist::list.map(list_lock, mmodel)
  vec_mpred = unlist(rlist::list.map(list_lock, mpred))
  return(list(list_mmodel = list_mmodel, vec_mpred = vec_mpred))
}
