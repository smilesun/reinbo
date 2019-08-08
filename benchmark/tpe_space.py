#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 15.2.2019

@author: Jiali Lin
"""

from hyperopt import hp
import hyperopt.pyll.stochastic

# Define the search space
space = {
        # Step 1:
        'Preprocess': hp.choice('pre',
                ['cpoScale()',
                 'cpoScale(scale = FALSE)',
                 'cpoScale(center = FALSE)',
                 'cpoSpatialSign()',
                 'NA']),


        # Step 2:
        'FeatureFilter': hp.choice('feature', [
                {'filter': 'cpoFilterAnova(perc)',
                 'perc': hp.uniform('ano_per', 0.1, 1)},

                {'filter': 'cpoFilterKruskal(perc)',
                 'perc': hp.uniform('kru_per', 0.1, 1)},

                {'filter': 'cpoFilterUnivariate(perc)',
                 'perc': hp.uniform('uni_per', 0.1, 1)},

                {'filter': 'cpoPca(center = FALSE, rank)',
                 'rank': hp.uniform('pca_rank', 0.1, 1)},

                {'filter': 'NA'}]),


        # Step 3:
        'Classifier': hp.choice('classify_model', [
                {'model': 'kknn',
                 'k': 1 + hp.randint('kknn_k', 19)},

                {'model': 'ksvm',
                 'C': hp.uniform('ksvm_C', 2**(-15), 2**(15)),
                 'sigma': hp.uniform('ksvm_sigma', 2**(-15), 2**(15))},

                {'model': 'ranger',
                 'mtry': hp.uniform('ranger_mtry', 0.1, 0.66666),
                 'sample.fraction': hp.uniform('ranger_fra', 0.1, 1)},

                {'model': 'xgboost',
                 'eta': hp.uniform('xgboost_eta', 0.001, 0.3),
                 'max_depth': 1 + hp.randint('xgboost_depth', 14),
                 'subsample': hp.uniform('xgboost_sub', 0.5, 1),
                 'colsample_bytree': hp.uniform('xgboost_col', 0.5, 1),
                 'min_child_weight': hp.uniform('xgboost_min', 0, 50)},

                {'model': 'naiveBayes',
                 'laplace': hp.uniform('bay_laplace', 0.01, 100)}

                 ])}



# Sample one configuration:
# print(hyperopt.pyll.stochastic.sample(space))
#print(hyperopt.pyll.stochastic.sample(space))
#106 {'Classifier': {'model': 'ranger', 'mtry': 0.574453305013119, 'sample.fracti
#107 on': 0.8656502995483121}, 'FeatureFilter': {'filter': 'cpoFilterAnova(perc)'
#108 , 'perc': 0.3726989872044636}, 'Preprocess': 'NA'}
