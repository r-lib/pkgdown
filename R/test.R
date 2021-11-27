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
#' magrittr::subtract(10, 1)
#' ```
#'
#' @name test-links
#' @keywords internal
#' @family tests
#' @examples
#' magrittr::subtract(10, 1)
#'
#' library(magrittr, warn.conflicts = FALSE)
#' subtract(10, 1)
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

#' Test case: don't
#'
#' @name test-dont
#' @keywords internal
#' @family tests
#' @examples
#' \dontrun{
#'   stop("This is an error!", call. = FALSE)
#' }
#'
#' # Inline \donttest is silently ommitted
#' \donttest{message("Hi!")}
#'
#' # Block \donttest indicated with comments
#' \donttest{
#' # This is a comment
#' 1 + 3
#' }
#'
#' # And works even when not at the top level
#' if (TRUE) {
#'   \donttest{
#'   1 + 2
#'   }
#' }
#'
#' answer <- 1
#' \dontshow{
#' answer <- 42
#' }
#' answer # should be 42
#'
#' # To hide the \dontshow part, for conditional examples
#' \dontshow{if (FALSE) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
#' answer <- 43
#' \dontshow{\}) # examplesIf}
#' answer # should be still 42
#'
#' # But this one runs, and the condition is hidden
#' \dontshow{if (TRUE) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
#' answer <- 43
#' \dontshow{\}) # examplesIf}
#' answer

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
#' cat(crayon::red("This is red"), "\n")
#' cat(crayon::blue("This is blue"), "\n")
#'
#' message(crayon::green("This is green"))
#'
#' warning(crayon::bold("This is bold"))
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
#' ```R
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
