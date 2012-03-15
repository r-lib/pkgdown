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

#' Render topic html page.
#' 
#' @param data Data for the template - should usually be created by calling
#'   \code{\link{to_html}} on the result of \code{\link{parse_rd}}
#' @importFrom whisker whisker.render
#' @examples
#' rd <- parse_rd("colSums", "base")
#' html <- to_html(rd)
#' render_topic(html)
render_topic <- function(data, path = "") {
  template <- readLines(find_template("topic"))
  
  rendered <- whisker.render(template, data)
  cat(rendered, file = path)
}