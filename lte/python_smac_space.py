# Import ConfigSpace and different types of parameters
from smac.configspace import ConfigurationSpace
from ConfigSpace.hyperparameters import CategoricalHyperparameter, \
    UniformFloatHyperparameter, UniformIntegerHyperparameter
from ConfigSpace.conditions import InCondition

# Import SMAC-utilities
from smac.tae.execute_func import ExecuteTAFuncDict
from smac.scenario.scenario import Scenario
from smac.facade.smac_facade import SMAC

cs = ConfigurationSpace()

# We define a few possible types of SVM-kernels and add them as "kernel" to our cs
step1 = CategoricalHyperparameter("Preprocess", ['cpoScale()', 'cpoScale(scale = FALSE)', 'cpoScale(center = FALSE)', 'cpoSpatialSign()', 'NA'], default_value="NA")
cs.add_hyperparameter(step1)

step2 = CategoricalHyperparameter("FeatureFilter", ['cpoFilterAnova(perc=perc_val)', 'cpoFilterKruskal(perc=perc_val)', 'cpoFilterUnivariate(perc=perc_val)', 'cpoPca(center = FALSE, rank = rank_val)', 'NA'], default_value = "NA")
cs.add_hyperparameter(step2)
anova_perc = UniformFloatHyperparameter("fe_anova_perc", 0.1, 1, default_value = 0.1)
kruskal_perc = UniformFloatHyperparameter("fe_kruskal_perc", 0.1, 1, default_value = 0.1)
univar_perc = UniformFloatHyperparameter("fe_univar_perc", 0.1, 1, default_value = 0.1)
pca_perc = UniformFloatHyperparameter("fe_pca_rank", 0, 0.9, default_value = 0.1)
cs.add_hyperparameters([anova_perc, kruskal_perc, univar_perc, pca_perc])

step2_child_anova = InCondition(child=anova_perc, parent=step2, values=["cpoFilterAnova(perc=perc_val)"])
step2_child_kruskal = InCondition(child=kruskal_perc, parent=step2, values=["cpoFilterKruskal(perc=perc_val)"])
step2_child_univar = InCondition(child=univar_perc, parent=step2, values=["cpoFilterUnivariate(perc=perc_val)"])
step2_child_pca = InCondition(child=pca_perc, parent=step2, values=["cpoPca(center = FALSE, rank = rank_val)"])
cs.add_conditions([step2_child_anova, step2_child_kruskal, step2_child_univar, step2_child_pca])

step3 = CategoricalHyperparameter("Model", ['kknn', 'ksvm', 'ranger', 'xgboost', 'naiveBayes'])
cs.add_hyperparameter(step3)

hyper_kknn =  UniformIntegerHyperparameter("lrn_kknn_k", 1, 19, default_value = 1)
hyper_ksvm_C = UniformFloatHyperparameter("lrn_svm_C", 2**(-15), 2**(15), default_value = 1)

hyper_ksvm_sigma = UniformFloatHyperparameter("lrn_svm_sigma", 2**(-15), 2**(15), default_value = 1)

hyper_ranger_mtry = UniformFloatHyperparameter("lrn_ranger_mtry", 0.1, 0.66666, default_value = 0.1)
hyper_ranger_sample_fraction = UniformFloatHyperparameter("lrn_ranger_sample.fraction", 0.1, 1, default_value = 0.1)
hyper_xgboost_eta = UniformFloatHyperparameter('lrn_xgboost_eta', 0.001, 0.3, default_value = 0.1)
hyper_xgboost_max_depth = UniformIntegerHyperparameter('lrn_xgboost_max_depth', 1, 14, default_value = 5)
hyper_xgboost_subsample = UniformFloatHyperparameter('lrn_xgboost_subsample', 0.5, 1, default_value = 0.5)
hyper_xgboost_colsample_bytree = UniformFloatHyperparameter('lrn_xgboost_colsample_bytree', 0.5, 1, default_value = 0.5)
hyper_xgboost_min_child_weight = UniformFloatHyperparameter('lrn_xgboost_min_child_weight', 0, 50, default_value = 0.5)
hyper_naiveBayes = UniformFloatHyperparameter('lrn_naiveBayes_laplace', 0.01, 100, default_value = 0.01)

cs.add_hyperparameters([hyper_kknn, hyper_ksvm_C, hyper_ksvm_sigma, hyper_ranger_mtry, hyper_ranger_sample_fraction, hyper_xgboost_eta, hyper_xgboost_max_depth, hyper_xgboost_subsample, hyper_xgboost_colsample_bytree, hyper_xgboost_min_child_weight, hyper_naiveBayes])

step3_child_kknn = InCondition(child = hyper_kknn, parent = step3, values = ["kknn"])
#cs.add_conditions([step3_child_kknn])
step3_child_ksvm_c = InCondition(child = hyper_ksvm_C, parent = step3, values = ["ksvm"])
#cs.add_conditions([step3_child_ksvm_c])
step3_child_ksvm_sigma = InCondition(child = hyper_ksvm_sigma, parent = step3, values = ["ksvm"])
#cs.add_conditions([step3_child_ksvm_sigma])
##
step3_child_ranger_mtry = InCondition(child = hyper_ranger_mtry, parent = step3, values = ["ranger"])
step3_child_ranger_sample_fraction = InCondition(child = hyper_ranger_sample_fraction, parent = step3, values = ["ranger"])
##

step3_child__xgboost_eta = InCondition(child = hyper_xgboost_eta, parent = step3, values = ["xgboost"])
step3_child__xgboost_max_depth = InCondition(child = hyper_xgboost_max_depth, parent = step3, values = ["xgboost"])
step3_child__xgboost_subsample = InCondition(child = hyper_xgboost_subsample, parent = step3, values = ["xgboost"])
step3_child__xgboost_colsample_bytree = InCondition(child = hyper_xgboost_colsample_bytree, parent = step3, values = ["xgboost"])
step3_child__xgboost_min_child_weight = InCondition(child = hyper_xgboost_min_child_weight, parent = step3, values = ["xgboost"])
##
step3_child__naiveBayes_laplace = InCondition(child = hyper_naiveBayes, parent = step3, values = ["naiveBayes"])

cs.add_conditions([step3_child_kknn, step3_child_ksvm_c, step3_child_ksvm_sigma, step3_child_ranger_mtry, step3_child_ranger_sample_fraction, step3_child__xgboost_eta, step3_child__xgboost_subsample, step3_child__xgboost_max_depth, step3_child__xgboost_colsample_bytree, step3_child__xgboost_min_child_weight, step3_child__naiveBayes_laplace])

cfg = cs.sample_configuration()
stub = {k : cfg[k] for k in cfg if cfg[k]}
