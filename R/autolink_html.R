#' Automatically link references and articles in an HTML page
#'
#' Deprecated: please use [downlit::downlit_html_path] instead.
#'
#' @param input,output Input and output paths for HTML file
#' @param local_packages A named character vector providing relative paths
#'   (value) to packages (name) that can be reached with relative links
#'   from the target HTML document.
#' @export
#' @keywords internal
#' @examples
#' \dontrun{
#' autolink_html("path/to/file.html",
#'   local_packages = c(
#'     shiny = "shiny",
#'     shinydashboard = "shinydashboard"
#'   )
#' )
#' }
autolink_html <- function(input, output = input, local_packages = character()) {
  withr::local_options(list(
    downlit.package = "",
    downlit.local_packages = local_packages
  ))

  html <- xml2::read_html(input, encoding = "UTF-8")
  downlit::downlit_html_node(html)

  xml2::write_html(html, output, format = FALSE)
  invisible()
}
