#' Package topics file documentation.
#'
#' Items can be accessed by \emph{\code{list()}}\code{$file_name}
#' @param package package to explore
#' @return \code{\link{list}} containing the documentation file of each file of a package
#' @keywords internal
#' @author Hadley Wickham
pkg_topics_rd <- function(package) {
  rd <- tools:::fetchRdDB(pkg_rddb_path(package))
  lapply(rd, name_rd)
}
