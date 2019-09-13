# Parameter set tree:
step1 = ParamSetTree$new("pre",
                         ParamCategorical$new(id = "Preprocess",
                                              values = c("cpoScale()", "cpoScale(scale = FALSE)", "cpoScale(center = FALSE)", "cpoSpatialSign()", "NA"))) 

step2 = ParamSetTree$new("filter",
                         ParamCategorical$new(id = "Filter",  
                                              values = c("cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoPca(center = FALSE, rank)", "cpoFilterUnivariate(perc)", "NA")), 
                         addDep(ParamReal$new(id = "perc", lower = .1, upper = 1),
                                did = "Filter", expr = quote(Filter %in% c("cpoFilterAnova(perc)", "cpoFilterKruskal(perc)", "cpoFilterUnivariate(perc)"))),
                         addDep(ParamReal$new(id = "rank", lower = .1, upper = 1),
                                did = "Filter", expr = quote(Filter == "cpoPca(center = FALSE, rank)")))

step3 = ParamSetTree$new("class",
                         ParamCategorical$new(id = "Classify",
                                              values = c("kknn", "ksvm", "xgboost", "ranger", "naiveBayes")),
                         
                         addDep(ParamInt$new(id = "k", lower = 1L, upper = 20L),
                                did = "Classify", expr = quote(Classify == "kknn")),
                         
                         addDep(ParamReal$new(id = "C", lower = 2^(-15), upper = 2^(15)),
                                did = "Classify", expr = quote(Classify == "ksvm")),
                         
                         addDep(ParamReal$new(id = "sigma", lower = 2^(-15), upper = 2^(15)),
                                did = "Classify", expr = quote(Classify == "ksvm")),
                         
                         addDep(ParamReal$new(id = "mtry", lower = 1/10, upper = 1/1.5),
                                did = "Classify", expr = quote(Classify == "ranger")),
                         
                         addDep(ParamReal$new(id = "sample.fraction", lower = .1, upper = 1),
                                did = "Classify", expr = quote(Classify == "ranger")),
                         
                         addDep(ParamReal$new(id = "eta", lower = .001, upper = .3),
                                did = "Classify", expr = quote(Classify == "xgboost")),
                         
                         addDep(ParamInt$new(id = "max_depth", lower = 1L, upper = 15L),
                                did = "Classify", expr = quote(Classify == "xgboost")),
                         
                         addDep(ParamReal$new(id = "subsample", lower = .5, upper = 1),
                                did = "Classify", expr = quote(Classify == "xgboost")),
                         
                         addDep(ParamReal$new(id = "colsample_bytree", lower = .5, upper = 1),
                                did = "Classify", expr = quote(Classify == "xgboost")),
                         
                         addDep(ParamReal$new(id = "min_child_weight", lower = 0, upper = 50),
                                did = "Classify", expr = quote(Classify == "xgboost")),
                         
                         addDep(ParamReal$new(id = "laplace", lower = 0.01, upper = 100),
                                did = "Classify", expr = quote(Classify == "naiveBayes"))
)

step2$setChild(step3)
step1$setChild(step2)












