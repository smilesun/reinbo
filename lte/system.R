sys = Sys.info()
flag_local = as.list(sys)$user == "JialiLin"
mconf.file = NULL

if (flag_local) {
  reticulate::use_python("/usr/local/bin/python3")
  mconf.file = NA
} else {
  reticulate::use_condaenv("w_env")
  mconf.file = "lrz.batchtools.conf.R"
}

