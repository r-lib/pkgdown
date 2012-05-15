inst_path <- function() {
  srcref <- attr(find_template, "srcref")
  
  if (is.null(srcref)) {
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