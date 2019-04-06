Q_table_Env = R6::R6Class(
  "Q_table_Env",
  inherit = rlR::Environment,
  public = list(
    step_cnt = NULL,
    s_r_d_info = NULL,
    task = NULL,
    mbo_cache = NULL,       # store pipeline, hyperparameter set and corresponding performance for MBO
    model_best_perf = NULL, # best performance of sampled model until now
    model_trained = NULL,   # store all trained models (limited to budget)
    budget = NULL,          # maximun models to be evaluated
    measure = NULL,
    cv_instance = NULL,
    initialize = function(task, budget, measure, cv_instance){
      self$flag_continous = FALSE    # non-continuous action
      self$flag_tensor = FALSE       # no use of cnn       
      self$act_cnt = g_act_cnt       # 5 available operators/actions at each stage
      self$state_dim = g_state_dim
      self$step_cnt = 0L
      self$s_r_d_info = list(
        state = "s",
        reward = 0,
        done = FALSE,
        info = list())
      self$task = task
      self$mbo_cache = hash()
      self$model_trained = NULL
      self$budget = budget
      self$measure = measure
      self$cv_instance = cv_instance
    },

    evaluateArm = function(vec_arm) {
      print(vec_arm)
      return(vec_arm)
    },
    
    # This function will be called at each step of the learning
    step = function(action) {
      action = g_operators[, self$step_cnt + 1][action]
      self$s_r_d_info[["state"]] = paste0(self$s_r_d_info[["state"]], "-[", action, "]")
      print(self$s_r_d_info[["state"]])
      self$s_r_d_info[["reward"]] = 0
      self$step_cnt = self$step_cnt + 1L
      if (self$step_cnt >= g_max_depth) {
        model = g_getRLPipeline(self$s_r_d_info[["state"]])
        print(paste(model, collapse = " --> "))
        # stop RL agent if no enough budget for this episode:
        model_id = paste(model, collapse = "\t") 
        if (has.key(model_id, self$mbo_cache)){
          require_budget =  g_mbo_iter*sum(getParamLengths(g_getParamSetFun(model)))
        } else {
          require_budget =  (g_init_design + g_mbo_iter)*sum(getParamLengths(g_getParamSetFun(model)))
        }
        if(self$budget < require_budget) stop("too small total budget for reinbo table!")
        if (self$budget - length(self$model_trained) < require_budget) {
          self$agent$interact$idx_episode = self$agent$interact$maxiter
          self$s_r_d_info[["done"]] = TRUE
        } else {
          # train model with hyperparameter tuning:
          self$tuning(model)
          self$s_r_d_info[["reward"]] = self$model_best_perf  # best performance of the model until now
          self$s_r_d_info[["done"]] = TRUE
          print(paste("Best Perfomance:", self$model_best_perf))
          }
      }
      return(self$s_r_d_info)
    },
    
    
    # This function will be called at the beginning of the learning and at the end of each episode
    reset = function() {
      self$step_cnt = 0
      self$s_r_d_info[["state"]] = "s"
      self$s_r_d_info[["done"]] = FALSE
      self$s_r_d_info
    },
    
    
    # Hyperparameter tuning for generated model, return best performance as reward and update mbo_cache
    tuning = function(model) {
      model_id = paste(model, collapse = "\t")  # mdoel_id for search in mbo_cache
      ps = g_getParamSetFun(model)              # generate parameter set
      
      # check if we have already evaluated this model
      
      # if already in mbo_cache:
      if (has.key(model_id, self$mbo_cache)){
        previous_perf = max(self$mbo_cache[[model_id]][ , "y"])            # best performance until now
        epis_unimproved = self$mbo_cache[[model_id]][1, "epis_unimproved"] # number of episodes that performance has not been improved
        # if in more than 2 episodes that the performance of this model has not been improved,
        # stop further hyperparameter tuning:
        if (epis_unimproved > 2) {
          self$model_best_perf = previous_perf
        } else {
          # else: use parameter set and performance in memory as initial design
          design = self$mbo_cache[[model_id]][ , -length(self$mbo_cache[[model_id]])]
          # run several iterations of MBO:
          run = mbo_fun(self$task, model, design, self$measure, self$cv_instance)
          # best accuracy:
          self$model_best_perf = run$y
          # update mbo_cache:
          self$mbo_cache[[model_id]] = run$opt.path$env$path
          # add result to self$model_trained:
          new = run$opt.path$env$path$y[run$opt.path$env$dob != 0]
          self$model_trained = c(self$model_trained, new)   
          # check if the performance of this model has been improved in this episode:
          if (run$y <= previous_perf) {
            self$mbo_cache[[model_id]]["epis_unimproved"] = epis_unimproved + 1
          } else {
            self$mbo_cache[[model_id]]["epis_unimproved"] = 0
          }
        }
      } else {
        
        # if not in mbo_cache:
        design = generateDesign(n = g_init_design*sum(getParamLengths(ps)), par.set = ps)
        run = mbo_fun(self$task, model, design, self$measure, self$cv_instance)
        self$model_best_perf = run$y
        self$mbo_cache[[model_id]] = run$opt.path$env$path
        self$mbo_cache[[model_id]]["epis_unimproved"] = 0
        new = run$opt.path$env$path$y
        self$model_trained = c(self$model_trained, new)
      }
    }
  )
)


