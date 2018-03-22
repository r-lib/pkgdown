#' Automatic link references and articles in an HTML package
#'
#' @description
#' The autolinker is built around two XPath expressions:
#'
#' * `//pre[contains(@class, 'r')]`:
#'   this finds all `<div>`s with class `sourceCode` and `r`. The contents
#'   must be syntax-highlighted using [pygments](http://pygments.org/).
#'   (This is default in [rmarkdown::html_document] when `theme = NULL`.)
#'
#' * `.//code[count(*) = 0]`: this finds all `<code>` that contain only
#'   text (and no other tags).
#'
#' @details
#' Currently the following expressions are linked:
#'
#' * Function calls, `foo()`
#' * Function calls qualified with the package name, `bar::foo()`
#' * Symbols qualified with the package name, `bar::baz`
#' * Help calls, `?foo`, `package?foo`, and `?bar::foo`
#' * Vignette calls, `vignette(baz)`, `vignette(baz, package = "bar")`
#'
#' Calls to `library()` and `require()` are used to find the topics connected
#' to unqualified references.
#'
#' @param input,output Input and output paths for HTML file
#' @param local_packages A named character vector providing relative paths
#'   (value) to packages (name) that can be reached with relative links
#'   from the target HTML document.
#' @export
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
  scoped_package_context(
    package = "",
    topic_index = character(),
    article_index = character(),
    local_packages = local_packages
  )
  scoped_file_context()

  html <- xml2::read_html(input, encoding = "UTF-8")
  tweak_code(html)

  xml2::write_html(html, output, format = FALSE)
  invisible()
}
