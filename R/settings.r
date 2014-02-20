load_settings <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)
  desc_path <- file.path(pkg$path, "DESCRIPTION")
  desc_opts <- read.dcf(desc_path, fields = "Staticdocs")[[1, 1]]

  if (is.na(desc_opts)) {
    opts <- list()
  } else {
    opts <- eval(parse(text = desc_opts))
  }

  opts
}
