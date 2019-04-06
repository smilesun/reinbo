# Random Search algorithm:
opt.random.search = function(task, budget, measure, train_set = NULL) {
  subTask = task
  if (!is.null(train_set)) subTask = subsetTask(task, train_set)
  inner_loop = makeResampleInstance("CV", iters = getGconf()$NCVInnerIter, stratify = TRUE, subTask)
  ps <<- step1$sample(budget)
  for (i in 1:budget) {
    perf = mlr_fun(subTask, ps[i, ], measure, cv_instance = inner_loop)
    ps[i, "perf"] = perf
  }
  mmodel = ps[ps$perf == min(ps$perf),][1,]
  mmodel$perf = NULL
  return(mmodel)
}


# Mlr function: evaluate sampled model
mlr_fun = function(task, model, measure, cv_instance) {
  lrn = genLearner(task, model, measure)
  perf = resample(lrn, task, resampling = cv_instance, measures = measure, show.info = FALSE)$aggr
  return(perf)
}


# Predict function: evaluate best model on test dataset
lock_eval.random.search = function(task, measure, train_set, test_set, best_model){
  lrn = genLearner(task, best_model, measure)
  mod = train(lrn, task, subset = train_set)
  pred = predict(mod, task, subset = test_set)
  perf = performance(pred, measures = measure)
  return(perf)
}

# Generate mlr learner for configuration:
genLearner = function(task, model, measure){
  p = getTaskNFeats(task)
  lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('classif.%s', par.vals = ps.learner)",
                model$Preprocess[1], model$Filter[1], model$Classify[1])
  lrn = gsub(pattern = "perc", x = lrn, replacement = "perc = model$perc", fixed = TRUE)
  lrn = gsub(pattern = "rank", x = lrn, replacement = "rank = as.integer(max(1, round(p*model$rank)))", fixed = TRUE)
  lrn = gsub(pattern = "NA %>>%", x = lrn, replacement = "", fixed = TRUE)
  ps.learner = model[, -(1:5)]         ## delete parameters irrelevant to classifier
  ps.learner = as.list(ps.learner)
  ps.learner[is.na(ps.learner)] = NULL
  if (model$Classify[1] == "ranger") {
    p1 = p
    if (!is.na(model$perc)) {p1 = max(1, round(p*model$perc))}
    if (!is.na(model$rank)) {p1 = max(1, round(p*model$rank))}
    ps.learner$mtry = max(1, as.integer(p1*model$mtry))
  }
  lrn = eval(parse(text = lrn))
  return(lrn)
}

