#' Test case: lists
#'
#' @noMd
#' @description
#' \itemize{\item a}
#'
#' \itemize{
#'   \item a
#'   \item This is an item...
#'
#'     That spans multiple paragraphs.
#' }
#'
#' \enumerate{
#'   \item a
#'   \item b
#' }
#'
#' \describe{
#'   \item{a}{1}
#'   \item{b}{2}
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
