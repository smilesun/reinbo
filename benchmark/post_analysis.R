result_list = reduceResultsList(ids = findDone(), fun = function(job, res) {
    model = res$mmodel$Model
      operators = strsplit(as.character(model), "\t")[[1]]
      data.frame(pre = operators[1], filter = operators[2], classifier = operators[3])
})
result = rbindlist(result_list)
Freq = c(as.list(table(result$pre)), as.list(table(result$filter)), as.list(table(result$classifier)))
