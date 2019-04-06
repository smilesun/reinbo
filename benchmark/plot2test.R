# Plot and test

library(data.table)
library(ggplot2)
library(tidyr)
library(reshape2)
library(xtable)
library(knitr)


## preparation
dt_new = readRDS("reinbo_new_cut_episode.rds")
dt_new$algorithm = "reinbo"

#dt_reinbo_old = read.csv("../Experiment_results/ML-ReinBo.csv")
#dt_reinbo_old$algo = "reinbo2"
dt_reinbo_old = NULL
temp = read.csv("../Experiment_results/Auto-sklearn.csv")
temp$algorithm = "Autosklearn"
dt_reinbo_old = rbind(dt_reinbo_old, temp)
#
#temp = read.csv("../Experiment_results/Auto-sklearn_light.csv")
#temp$algo = "Autosklearn-light"
#dt_reinbo_old = rbind(dt_reinbo_old, temp)

temp = read.csv("../Experiment_results/TPE.csv")
temp$algorithm = "TPE"
dt_reinbo_old = rbind(dt_reinbo_old, temp)

#
temp = read.csv("../Experiment_results/TPOT.csv")
temp$algorithm = "Tpot"
dt_reinbo_old = rbind(dt_reinbo_old, temp)
#
temp = read.csv("../Experiment_results/TPOT_light.csv")
temp$algorithm = "Tpot-light"
dt_reinbo_old = rbind(dt_reinbo_old, temp)
#
temp = read.csv("../Experiment_results/Random_search.csv")
temp$algorithm = "RandomSearch"
dt_reinbo_old = rbind(dt_reinbo_old, temp)



dt_reinbo_old$prob.name = dt_reinbo_old$name
dt_res = rbind(dt_reinbo_old[, c("prob.name", "mmce", "algorithm")], dt_new[, c("prob.name", "mmce", "algorithm")])

# check if all jobs finished
dt_res[, .N, by = "prob.name"]

## table
dt_light = dt_res[, .(mmce = mean(mmce)), by = .(prob.name, algorithm)]
dt_light

dt_table = spread(dt_light, key = "algorithm", value = "mmce")
dt_table
cns = colnames(dt_table)
cns[1] = "dataset name"
colnames(dt_table) = cns
xtable(dt_table)
knitr::kable(dt_table)
ltxtable=xtable(dt_table, align=rep("l",ncol(dt_table)+1), digits = 4)
print(ltxtable, floating=TRUE, hline.after=NULL, include.rownames=TRUE, include.colnames=TRUE)  # tested

# example to add asterix
# pval <- rev(sort(c(outer(1:6, 10^-(1:3)))))
# symp <- symnum(pval, corr = FALSE,
#                  cutpoints = c(0,  .001,.01,.05, .1, 1),
#                                 symbols = c("***","**","*","."," "))
# noquote(cbind(P.val = format(pval), Signif = symp))

## plot
size = 10 # font size
gp = ggplot() + geom_boxplot(data = as.data.frame(dt_res), aes(x = algorithm, y = mmce, fill = algorithm)) + theme_bw() + theme(axis.text.x = element_text(angle = 90, size = size), axis.text.y = element_text(size = size), axis.title = element_text(size = size), strip.text = element_text(size=size), legend.text = element_text(size = size), legend.position="bottom") + facet_wrap("prob.name", scale = "free_y", ncol = 3)
#ggsave(gp, file = "prob_algo_repli_compare.pdf", width=3, height=3, units="in", scale=5, device = pdf)
ggsave(gp, file = "prob_algo_repli_compare.pdf", device = "pdf",scale = 0.9)

##  test
fun_best_against_other = function(temp, candiate = NULL) {
  light = temp[, .(mmce = mean(mmce)), by = "algorithm"] # take mean value
  ind = light[, .(which.min(mmce))]
  prob_name = unique(temp$prob.name)
  ref = light$algorithm[as.vector(as.matrix(ind))]
  #cat(sprintf(" \nprob *** %s*** of best algorithm name ***%s***\n", prob_name,  ref))
  if(!is.null(candiate)) {
    checkmate::assert_character(candiate)
    ref = candiate
  }
  moptions = unique(temp$algorithm)
  #moptions = setdiff(moptions, ref)
  x = temp[algorithm == ref]$mmce
  res = lapply(moptions, function(name) {
    y = temp[algorithm == name]$mmce
    if (length(x) != length(y)) return(100)
    worse_than_best = (wilcox.test(y, x, alternative = "greater", exact = FALSE)$p.value < 0.05)
    better_than_best  = (wilcox.test(x, y, alternative = "greater", exact = FALSE)$p.value < 0.05)
    val = temp[algorithm == name, mean(mmce)]
    strval = as.character(sprintf("%.4f", val))
    if (is.null(candiate)) {
      if (worse_than_best) return(strval)  # -1 lose
      if ((!better_than_best) & (name ==ref)) return(paste0("\\underline{\\textbf{", strval, "}}"))  # 0 tie
      else return(paste0("\\textbf{", strval, "}"))  # win!
    }
    # candiate is not null
    # win lose
    if (worse_than_best) return(-1)  # -1 lose
    if (!better_than_best) return(0)  # 0 tie
    return(1)  # win!
    })
  names(res) = moptions
  res$best_algo = ref
  as.data.table(res)
}

dt_winner = dt_res[, fun_best_against_other(.SD), by = .(prob.name), .SDcols = colnames(dt_res)]
res = knitr::kable(dt_winner, format = "latex", digits = 4, escape = F)
capture.output(print(res), file = "latex.txt")

algos = as.character(unique(dt_res$algorithm))
name = "reinbo"  # suppose if reinbo is the best
dt_res[, fun_best_against_other(.SD, name), by = .(prob.name), .SDcols = colnames(dt_res)]
