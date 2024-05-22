test_that("validations yaml specification", {
  build_bslib_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    build_bslib(pkg)
  }

  expect_snapshot(error = TRUE, {
    build_bslib_(template = list(theme = 1, bootstrap = 5))
    build_bslib_(template = list(theme = "fruit", bootstrap = 5))
    build_bslib_(template = list(`theme-dark` = "fruit", bootstrap = 5))
  })
})
