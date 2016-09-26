read_meta <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  path <- file.path(pkg$path, "_staticdocs.yml")

  if (!file.exists(path)) {
    yaml <- list()
  } else {
    yaml <- yaml::yaml.load_file(path)
  }

  yaml
}

