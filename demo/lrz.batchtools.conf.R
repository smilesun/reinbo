source("/home/hpc/pr74ze/ri89coc2/lrz_configs/config_files/batchtools/clusterFunctionsSlurmLrz.R")
cluster.functions = makeClusterFunctionsSlurmLrz("/home/hpc/pr74ze/ri89coc2/lrz_configs/config_files/batchtools/slurm_lmulrz.tmpl", array.jobs = FALSE)
default.resources = list(walltime = 3600L * 12, memory = 1024 * 3L, ntasks = 1L, ncpus = 1L, nodes = 1L, clusters = "serial")
max.concurrent.jobs = 999L 
