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
#'   \item{a}{1}
#'   \item{b}{2}
#'   \item{This is a very long definition term}{}
#' }
#' }
#' @keywords internal
#' @family tests
#' @name test-lists
NULL

#' Test case: links
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
#' x <- seq(0, 2 * pi, length = 25)
#' plot(x, sin(x))
NULL

#' Test case: don't
#'
#' @name test-dont
#' @keywords internal
#' @family tests
#' @examples
#' \dontrun{
#' 1 + 3
#' }
#'
#' \donttest{
#' 1 + 3
#' }
#'
#' answer <- 1
#' \dontshow{
#' answer <- 42
#' }
#' answer # should be 42
NULL


# Used for testing
#' @keywords internal
#' @importFrom MASS addterm
#' @export
MASS::addterm

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
#'
#' \dontrun{
#' stop("This is an error!", call. = FALSE)
#' }
#'
#' \donttest{
#' # This code won't generally be run by CRAN. But it
#' # will be run by pkgdown
#' b <- 10
#' a + b
#' }
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
