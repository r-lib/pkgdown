#' @importFrom stringr str_c
find_template <- function(name) {
  srcref <- attr(find_template, "srcref")
  
  if (is.null(srcref)) {
    # Probably in package
    system.file(package = "staticdocs")
  } else {
    # Probably in development
    base_path <- file.path(dirname(dirname(attr(srcref, "srcfile")$filename)),
      "inst")
  }

  file.path(base_path, "templates", str_c(name, ".html"))
}

#' @importFrom whisker whisker.render
render_topic <- function(rd, path = "") {
  template <- readLines(find_template("topic"))
  data <- to_html(rd)
  
  rendered <- whisker.render(template, data)
  cat(rendered, file = path)
}