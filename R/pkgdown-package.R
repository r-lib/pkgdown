#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom utils installed.packages
#' @import rlang
#' @import fs
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

release_bullets <- function() {
  c(
    "Check that [test/widget.html](https://pkgdown.r-lib.org/dev/articles/) responds to mouse clicks on 5/10/50",
    "Update translations with `potools::po_extract()` + `potools::po_update()`",
    "Use an LLM to proofread / fill in missing translations (see #2926)",
    "Compile po files with `potools::po_compile()`",
    "Update `vignette/translations.Rmd` with any new languages"
  )
}
