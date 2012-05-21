inst_path <- function() {
  envname <- environmentName(environment(inst_path))
  
  if (envname == "staticdocs") {
    # Probably in package
    system.file(package = "staticdocs")
  } else {
    # Probably in development
    file.path(dirname(dirname(attr(srcref, "srcfile")$filename)),
      "inst")
  }
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

rows_list <- function(df) {
  lapply(seq_len(nrow(df)), function(i) as.list(df[i, ]))
}