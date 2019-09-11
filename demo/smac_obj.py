import rpy2
import rpy2.robjects as robjects
import rpy2.robjects.numpy2ri
rpy2.robjects.numpy2ri.activate()
robjects.conversion.py2ri = rpy2.robjects.numpy2ri
from rpy2.robjects.packages import STAP
# if rpy2 < 2.6.1 do:
# from rpy2.robjects.packages import SignatureTranslatedAnonymousPackage
# STAP = SignatureTranslatedAnonymousPackage
with open('smac_obj.R', 'r') as f:
    string = f.read()
myfunc = STAP(string, "toy_smac_obj")
def smac_obj_from_cfg(cfg):
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
    return myfunc.toy_smac_obj(cfg)
