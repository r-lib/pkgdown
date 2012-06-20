inst_path <- function() {
  envname <- environmentName(environment(inst_path))
  
  if (envname == "staticdocs") {
    # Probably in package
    system.file(package = "staticdocs")
  } else {
    # Probably in development
    srcref <- attr(find_template, "srcref")
    path <- dirname(dirname(attr(srcref, "srcfile")$filename))
    file.path(path, "inst")
  }
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

rows_list <- function(df) {
  lapply(seq_len(nrow(df)), function(i) as.list(df[i, ]))
}

#' @importFrom markdown markdownToHTML
markdown <- function(x = NULL, path = NULL) {
  if (is.null(path)) {
    if (is.null(x) || x == "") return("")
  }
  
  (markdownToHTML(text = x, file = path,
    options = c("safelink", "use_xhtml", "smartypants")))
}

cloak_email <- function(x){
	sub('@', ' at ', x, fixed=TRUE)
}