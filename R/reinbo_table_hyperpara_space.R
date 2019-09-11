##### Parameter set of operators for hyperparameter tuning:
ps.ksvm = ParamHelpers::makeParamSet(
  ParamHelpers::makeNumericParam("C", lower = -15, upper = 15, trafo = function(x) 2^x),
  ParamHelpers::makeNumericParam("sigma", lower = -15, upper = 15, trafo = function(x) 2^x))

ps.ranger = ParamHelpers::makeParamSet(
  ParamHelpers::makeNumericParam("mtry", lower = 1/10, upper = 1/1.5),  ## range(p/10, p/1.5), p is the number of features
  ParamHelpers::makeNumericParam("sample.fraction", lower = .1, upper = 1))

ps.xgboost = ParamHelpers::makeParamSet(
  ParamHelpers::makeNumericParam("eta", lower = .001, upper = .3),
  ParamHelpers::makeIntegerParam("max_depth", lower = 1L, upper = 15L),
  ParamHelpers::makeNumericParam("subsample", lower = 0.5, upper = 1),
  ParamHelpers::makeNumericParam("colsample_bytree", lower = 0.5, upper = 1),
  ParamHelpers::makeNumericParam("min_child_weight", lower = 0, upper = 50)
  )

ps.kknn = ParamHelpers::makeParamSet(ParamHelpers::makeIntegerParam("k", lower = 1L, upper = 20L))

ps.naiveBayes = ParamHelpers::makeParamSet(ParamHelpers::makeNumericParam("laplace", lower = 0.01, upper = 100))

ps.filter = ParamHelpers::makeParamSet(ParamHelpers::makeNumericParam("perc", lower = .1, upper = 1))

ps.pca = ParamHelpers::makeParamSet(ParamHelpers::makeNumericParam("rank", lower = .1, upper = 1)) ## range(p/10, p), p is the number of features



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



