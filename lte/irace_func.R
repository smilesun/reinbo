# Irace algorithm:
opt.irace = function(task, budget, measure, train_set = NULL) {
  measure <<- measure
  subTask <<- task
  if (!is.null(train_set)) subTask <<- subsetTask(task, train_set)
  irace::irace(
    scenario = list(
      targetRunner = target.runner,
      instances = lapply(1:(getGconf()$NCVInnerIter*budget), function(x) 
        makeResampleInstance(makeResampleDesc("Holdout", split = 1 - 1/getGconf()$NCVInnerIter, stratify = TRUE), subTask)),
      maxExperiments = getGconf()$NCVInnerIter*budget
    ),
    parameters = readParameters("irace_space.txt", digits = 5, debugLevel = 0, text)
  )  
  load("./irace.Rdata")
  mmodel = getFinalElites(iraceResults = iraceResults, n = 1)
  return(mmodel)
}


# Target runner of Irace:
target.runner = function(experiment, config = list()) {
  rin = experiment$instance      ## holdout instance
  lrn = genLearner.irace(subTask, experiment$configuration)
  res = mlr::resample(lrn, subTask, resampling = rin, measures = measure, show.info = FALSE)
  return(list(cost = res$aggr))
}


# Predict function: evaluate best model on test dataset
lock_eval.irace = function(task, measure, train_set, test_set, best_model){
  ps = best_model
  ps$.ID. = NULL
  ps$.PARENT. = NULL 
  lrn = genLearner.irace(task, ps)
  mod = train(lrn, task, subset = train_set)
  pred = predict(mod, task, subset = test_set)
  perf = performance(pred, measures = measure)
  return(perf)
}

# Generate mlr learner for configuration:
genLearner.irace = function(task, configuration){
  ps = configuration  ## hypar-parameters
  ps$sigma = 2^(ps$sigma)
  ps$C = 2^(ps$C)
  lrn = sprintf("%s %%>>%% %s %%>>%% makeLearner('classif.%s', par.vals = ps.learner)",
                paste0(ps$Preprocess, "()"), paste0(ps$Filter, "()"), ps$Classify)
  lrn = gsub(pattern = "NA() %>>%", x = lrn, replacement = "", fixed = TRUE)
  # Preprocess:
  lrn = gsub(pattern = ".scale()", x = lrn, replacement = "(scale = FALSE)", fixed = TRUE)
  lrn = gsub(pattern = ".center()", x = lrn, replacement = "(center = FALSE)", fixed = TRUE)
  # Filter:
  lrn = gsub(pattern = ".perc()", x = lrn, replacement = "(perc = ps$perc)", fixed = TRUE)
  p = getTaskNFeats(task)
  lrn = gsub(pattern = ".rank()", x = lrn, replacement = "(center = FALSE, rank = as.integer(max(1, round(p*ps$rank))))", fixed = TRUE)
  ## delete parameters irrelevant to classifier
  ps.learner = as.list(ps)
  ps.learner$Preprocess = NULL
  ps.learner$Filter = NULL
  ps.learner$Classify = NULL
  ps.learner$perc = NULL
  ps.learner$rank = NULL
  ps.learner[is.na(ps.learner)] = NULL
  if (ps$Classify == "ranger") {
    p1 = p
    if (!is.na(ps$perc)) {p1 = max(1, round(p*ps$perc))}
    if (!is.na(ps$rank)) {p1 = max(1, round(p*ps$rank))}
    ps.learner$mtry = max(1, as.integer(p1*ps$mtry))
  }
  lrn = eval(parse(text = lrn))
  return(lrn)
}

