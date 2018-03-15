#' Render RMarkdown document in a fresh session
#'
#' @noRd
render_rmarkdown <- function(input, ..., quiet = TRUE) {

  if (!file_exists(input)) {
    stop("Can't find ", src_path(input), call. = FALSE)
  }

  args <- list(
    input = input,
    encoding = "UTF-8",
    envir = globalenv(),
    ...,
    quiet = quiet
  )

  path <- callr::r_safe(
    function(...) rmarkdown::render(...),
    args = args,
    show = !quiet
  )

  path
}
