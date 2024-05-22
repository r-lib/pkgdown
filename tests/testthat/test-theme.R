test_that("validations yaml specification", {
  build_bslib_ <- function(...) {
    pkg <- local_pkgdown_site(
      meta = list(template = list(..., bootstrap = 5, `light-switch` = TRUE))
    )
    build_bslib(pkg)
  }

  expect_snapshot(error = TRUE, {
    build_bslib_(theme = 1)
    build_bslib_(theme = "fruit")
    build_bslib_(`theme-dark` = "fruit")
  })
})
