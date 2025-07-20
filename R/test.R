#' Test case: lists
#'
#' @noMd
#' @description
#'
#' \subsection{Bulleted list}{
#' \itemize{
#'   \item a
#'   \item This is an item...
#'
#'     That spans multiple paragraphs.
#' }
#' }
#'
#' \subsection{Bulleted list (single item)}{
#' \itemize{\item a}
#' }
#'
#' \subsection{Numbered list}{
#' \enumerate{
#'   \item a
#'   \item b
#' }
#' }
#'
#' \subsection{Definition list}{
#' \describe{
#'   \item{short}{short}
#'   \item{short}{Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
#'   eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
#'   minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip
#'   ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
#'   voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
#'   sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt
#'   mollit anim id est laborum.}
#'   \item{Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
#'   eiusmod tempor incididunt ut labore et dolore magna aliqua.}{short}
#'   \item{Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
#'   eiusmod tempor incididunt ut labore et dolore magna aliqua.}{Lorem ipsum
#'   adipiscing elit, sed do  eiusmod tempor incididunt ut labore et dolore ad
#'   minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip
#'   ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
#'   voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
#'   sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt
#'   mollit anim id est laborum.}
#' }
#' }
#' @keywords internal
#' @family tests
#' @name test-lists
NULL

#' Test case: links
#'
#' ```{r}
#' jsonlite::minify("{}")
#' ```
#'
#' @name test-links
#' @keywords internal
#' @family tests
#' @examples
#' jsonlite::minify("{}")
#'
#' library(jsonlite, warn.conflicts = FALSE)
#' minify("{}")
NULL

#' Test case: figures
#'
#' \figure{bacon.jpg}
#'
#' @name test-figures
#' @keywords internal
#' @family tests
#' @examples
#' x <- seq(0, 2 * pi, length.out = 25)
#' plot(x, sin(x))
#'
#' plot(1:10)
#' lines(1:10)
#' text(2, 5, "Hello", srt = 30, cex = 2)
NULL

#' Test case: tables
#'
#' @name test-tables
#' @keywords internal
#' @family tests
#' @examples
#' gt::gt(head(mtcars))
NULL

#' Test case: don't
#'
#' @name test-dont
#' @keywords internal
#' @family tests
#' @examples
#' # \dontrun{} --------------------------------------------------------
#' # always shown; never run
#'
#' x <- 1
#' \dontrun{x <- 2}
#' \dontrun{
#'   x <- 3
#'   x <- 4
#' }
#' x # should be 1
#'
#' # \donttest{} -------------------------------------------------------
#' # only multiline are shown; always run
#'
#' x <- 1
#' \donttest{x <- 2}
#' \donttest{
#'   x <- 3
#'   x <- 4
#' }
#' x # should be 4
#'
#' # \testonly{} -----------------------------------------------------
#' # never shown, never run
#'
#' x <- 1
#' \testonly{x <- 2}
#' \testonly{
#'   x <- 3
#'   x <- 4
#' }
#' x # should be 1
#'
#' # \dontshow{} -------------------------------------------------------
#' # never shown, always run
#'
#' x <- 1
#' \dontshow{x <- 2}
#' \dontshow{
#'   x <- 3
#'   x <- 4
#' }
#' x # should be 4
#'
#' # @examplesIf ------------------------------------------------------
#' # If FALSE, wrapped in if; if TRUE, not seen
#'
#' x <- 1
#'
#' @examplesIf FALSE
#' x <- 2
#' @examplesIf TRUE
#' x <- 3
#' @examples
#' x # should be 3
NULL

#' Test case: params
#'
#' @name test-params
#' @param ... ellipsis
#' @keywords internal
#' @family tests
NULL

#' Test case: output styles
#'
#' @name test-output-styles
#' @keywords internal
#' @family tests
#'
#' @examples
#' # This example illustrates some important output types
#' # The following output should be wrapped over multiple lines
#' a <- 1:100
#' a
#'
#' cat("This some text!\n")
#' message("This is a message!")
#' warning("This is a warning!")
#'
#' # This is a multi-line block
#' {
#'   1 + 2
#'   2 + 2
#' }
NULL

#' Test case: long-lines
#'
#' The example results should have the copy button correctly placed when
#' scrollings
#'
#' @name test-long-lines
#' @keywords internal
#' @family tests
#' @examples
#' pkgdown:::ruler()
#'
#' cat(rep("x ", 100), sep = "")
#' cat(rep("xy", 100), sep = "")
#' cat(rep("x ", 100), sep = "")
#' cat(rep("xy", 100), sep = "")
NULL

#' Test case: crayon
#'
#' @name test-crayon
#' @keywords internal
#' @family tests
#'
#' @examples
#' cat(cli::col_red("This is red"), "\n")
#' cat(cli::col_blue("This is blue"), "\n")
#'
#' message(cli::col_green("This is green"))
#'
#' warning(cli::style_bold("This is bold"))
NULL

#' Test case: preformatted blocks & syntax highlighting
#'
#' Manual test cases for various ways of embedding code in sections.
#' All code blocks should have copy and paste button.
#'
#' # Should be highlighted
#'
#' Valid R code in `\preformatted{}`:
#'
#' ```
#' mean(a + 1)
#' ```
#'
#' R code in `R` block:
#'
#' ```R
#' mean(a + 1)
#' ```
#'
#' R code in `r` block:
#'
#' ```r
#' mean(a + 1)
#' ```
#'
#' Yaml
#'
#' ```yaml
#' yaml: [a, 1]
#' ```
#'
#' # Shouldn't be highlighted
#'
#' Non-R code in `\preformatted{}`
#'
#' ```
#' yaml: [a, b, c]
#' ```
#'
#' @name test-verbatim
#' @keywords internal
#' @family tests
NULL

#' Index
#'
#' @aliases test-index
#' @name index
#' @keywords internal
#' @family tests
NULL

#' Test case: \Sexpr[stage=render,results=rd]{"sexpr"}
#'
#' @name test-sexpr-title
#' @keywords internal
#' @family tests
NULL

#' Test case: math rendering in examples
#'
#' @param x \eqn{f(x) > 0}: inline equation
#'
#' @details
#' Display equation:
#'
#' \deqn{y = \alpha + \beta X + \varepsilon}
#'
#' Multi-line equation (correctly rendered by katex only):
#'
#' \deqn{\mathit{Minimize} \space l \\
#' \mathit{subject \space to} \\
#' \sum_{i = 1}^{I} x_i r_{ij} + y_j \geq t_j \forall j \in J \\
#' l \geq \frac{y_j}{t_j} \forall j \in J \\
#' \sum_{i = 1}^{I} x_i c_i \leq B}{
#' Minimize l subject to
#' sum_i^I (xi * rij) + yj >= tj for all j in J &
#' l >= (yj / tj) for all j in J &
#' sum_i^I (xi * ci) <= B}
#'
#' @name test-math-examples
#' @keywords internal
#' @family tests
NULL
