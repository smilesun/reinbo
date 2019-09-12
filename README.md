# Migration
Please visit 
https://github.com/compstat-lmu/paper_2019_ReinBO, this repo is at stake

# ReinBo
This repository is only for reproducing the experimental results of the following paper, which is currently under review. 

@article{xudong2019reinbo,
	title={ReinBo: Machine Learning pipeline search and configuration with Bayesian Optimization embedded Reinforcement Learning},
	author={Xudong Sun and Jiali Lin and Bernd Bischl},
	journal={arxiv preprint, https://arxiv.org/abs/1904.05381},
	number={1904.05381},
	year={2019}
}

Currently, the codes which could reproduce the experiments in the paper lies in the directory "benchmark". 

# To run the experiment
- install the required packages
- learn how to use the R cran package batchtools for large scale benchmark study
- in folder benchmark, execute main.R, then submit jobs according to "batchtools" API
- There are in total 660 jobs.
