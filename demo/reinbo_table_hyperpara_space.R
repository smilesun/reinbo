##### Parameter set of operators for hyperparameter tuning:
ps.ksvm = makeParamSet(
  makeNumericParam("C", lower = -15, upper = 15, trafo = function(x) 2^x),
  makeNumericParam("sigma", lower = -15, upper = 15, trafo = function(x) 2^x))

ps.ranger = makeParamSet(
  makeNumericParam("mtry", lower = 1/10, upper = 1/1.5),  ## range(p/10, p/1.5), p is the number of features
  makeNumericParam("sample.fraction", lower = .1, upper = 1))

ps.xgboost = makeParamSet(
  makeNumericParam("eta", lower = .001, upper = .3),
  makeIntegerParam("max_depth", lower = 1L, upper = 15L),
  makeNumericParam("subsample", lower = 0.5, upper = 1),
  makeNumericParam("colsample_bytree", lower = 0.5, upper = 1),
  makeNumericParam("min_child_weight", lower = 0, upper = 50)
  )

ps.kknn = makeParamSet(makeIntegerParam("k", lower = 1L, upper = 20L))

ps.naiveBayes = makeParamSet(makeNumericParam("laplace", lower = 0.01, upper = 100))

ps.filter = makeParamSet(makeNumericParam("perc", lower = .1, upper = 1))

ps.pca = makeParamSet(makeNumericParam("rank", lower = .1, upper = 1)) ## range(p/10, p), p is the number of features



##### Get parameter set for generated model:
g_getParamSetFun  = function(model) {
  ps.classif = sub(pattern = "classif", model[3], replacement = "ps")
  ps.classif = eval(parse(text = ps.classif))  # hyperparameter set for classifier
  if (model[2] == "NA") {
    return(ps.classif)
  } else if (length(grep(pattern = "perc", x = model)) > 0) {
    return(c(ps.classif, ps.filter))
  } else {
    return(c(ps.classif, ps.pca))
  }
}



