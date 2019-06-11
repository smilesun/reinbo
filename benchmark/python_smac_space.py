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

step2 = CategoricalHyperparameter("FeatureFilter", ['cpoFilterAnova(perc)', 'cpoFilterKruskal(perc)', 'cpoFilterUnivariate(perc)', 'cpoPca(center = FALSE, rank)', 'NA'], default_value = "NA")
cs.add_hyperparameter(step2)
anova_perc = UniformFloatHyperparameter("anova_perc", 0.1, 1, default_value = 0.1)
kruskal_perc = UniformFloatHyperparameter("kruskal_perc", 0.1, 1, default_value = 0.1)
univar_perc = UniformFloatHyperparameter("univar_perc", 0.1, 1, default_value = 0.1)
pca_perc = UniformFloatHyperparameter("pca_rank", 0, 0.9, default_value = 0.1)
cs.add_hyperparameters([anova_perc, kruskal_perc, univar_perc, pca_perc])

step2_child_anova = InCondition(child=anova_perc, parent=step2, values=["cpoFilterAnova(perc)"])
step2_child_kruskal = InCondition(child=kruskal_perc, parent=step2, values=["cpoFilterKruskal(perc)"])
step2_child_univar = InCondition(child=univar_perc, parent=step2, values=["cpoFilterUnivariate(perc)"])
step2_child_pca = InCondition(child=pca_perc, parent=step2, values=["cpoPca(center = FALSE, rank)"])
cs.add_conditions([step2_child_anova, step2_child_kruskal, step2_child_univar, step2_child_pca])

step3 = CategoricalHyperparameter("Model", ['kknn', 'ksvm', 'ranger', 'xgboost', 'naiveBayes'])
cs.add_hyperparameter(step3)

hyper_kknn =  UniformIntegerHyperparameter("kknn_k", 1, 19, default_value = 1)
hyper_ksvm_C = UniformFloatHyperparameter("svm_C", 2**(-15), 2**(15), default_value = 1)

hyper_ksvm_sigma = UniformFloatHyperparameter("svm_sigma", 2**(-15), 2**(15), default_value = 1)

hyper_ranger_mtry = UniformFloatHyperparameter("ranger_mtry", 0.1, 0.66666, default_value = 0.1)
hyper_ranger_sample_fraction = UniformFloatHyperparameter("ranger__fra", 0.1, 1, default_value = 0.1)
hyper_xgboost_eta = UniformFloatHyperparameter('xgboost_eta', 0.001, 0.3, default_value = 0.1)
hyper_xgboost_max_depth = UniformIntegerHyperparameter('xgboost_depth', 1, 14, default_value = 5)
hyper_xgboost_subsample = UniformFloatHyperparameter('xgboost_sub', 0.5, 1, default_value = 0.5)
hyper_xgboost_colsample_bytree = UniformFloatHyperparameter('xgboost_colsample_by_tree', 0.5, 1, default_value = 0.5)
hyper_xgboost_min_child_weight = UniformFloatHyperparameter('xgboost_min_child_weight', 0, 50, default_value = 0.5)
hyper_naiveBayes = UniformFloatHyperparameter('naiveBayes_laplace', 0.01, 100, default_value = 0.01)

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
step3_child__xgboost_colsample_bytree = InCondition(child = hyper_xgboost_subsample, parent = step3, values = ["xgboost"])
step3_child__xgboost_min_child_weight = InCondition(child = hyper_xgboost_min_child_weight, parent = step3, values = ["xgboost"])
##
step3_child__naiveBayes_laplace = InCondition(child = hyper_naiveBayes, parent = step3, values = ["naiveBayes"])

cs.add_conditions([step3_child_kknn, step3_child_ksvm_c, step3_child_ksvm_sigma, step3_child_ranger_mtry, step3_child_ranger_sample_fraction, step3_child__xgboost_eta, step3_child__xgboost_subsample, step3_child__xgboost_max_depth, step3_child__xgboost_colsample_bytree, step3_child__xgboost_min_child_weight, step3_child__naiveBayes_laplace])


scenario = Scenario({"run_obj": "quality",   # we optimize quality (alternatively runtime)
                     "runcount-limit": 200,  # maximum function evaluations
                     "cs": cs,               # configuration space
                     "deterministic": "true"
                     })

print("Optimizing! Depending on your machine, this might take a few minutes.")



def svm_from_cfg(cfg):
    """ Creates a SVM based on a configuration and evaluates it on the
    iris-dataset using cross-validation.

    Parameters:
    -----------
    cfg: Configuration (ConfigSpace.ConfigurationSpace.Configuration)
        Configuration containing the parameters.
        Configurations are indexable!

    Returns:
    --------
    A crossvalidated mean score for the svm on the loaded data-set.
    """
    # For deactivated parameters, the configuration stores None-values.
    # This is not accepted by the SVM, so we remove them.
    cfg = {k : cfg[k] for k in cfg if cfg[k]}
    # We translate boolean values:
    cfg["shrinking"] = True if cfg["shrinking"] == "true" else False
    # And for gamma, we set it to a fixed value or to "auto" (if used)
    if "gamma" in cfg:
        cfg["gamma"] = cfg["gamma_value"] if cfg["gamma"] == "value" else "auto"
        cfg.pop("gamma_value", None)  # Remove "gamma_value"

    clf = svm.SVC(**cfg, random_state=42)

    scores = cross_val_score(clf, iris.data, iris.target, cv=5)
    return 1-np.mean(scores)  # Minimize!


smac = SMAC(scenario=scenario, rng=np.random.RandomState(42),
        tae_runner=svm_from_cfg)
incumbent = smac.optimize()
inc_value = svm_from_cfg(incumbent)
print("Optimized Value: %.2f" % (inc_value))
