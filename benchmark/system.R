sys = Sys.info()
flag_local = as.list(sys)$user == "sunxd"
mconf.file = NULL

if (flag_local) {
  reticulate::use_python("~/anaconda3/bin/python")
  mconf.file = NA
} else {
  reticulate::use_condaenv("w_env")
  mconf.file = "lrz.batchtools.conf.R"
}

