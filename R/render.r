#' @importFrom stringr str_c
find_template <- function(name) {
  file.path(inst_path(), "templates", str_c(name, ".html"))
}

#' Render template.
#' 
#' @param name of the template
#' @param data data for the template
#' @param path location to create file.  If \code{""} (the default), 
#'   prints to standard out.
#' @importFrom whisker whisker.render
#' @examples
#' rd <- parse_rd("colSums", "base")
#' html <- to_html(rd)
#' render_topic(html)
render_template <- function(name, data, path = "") {
  template <- readLines(find_template(name))
  
  rendered <- whisker.render(template, data)
  cat(rendered, file = path)
}
