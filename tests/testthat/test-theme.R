test_that("check_bslib_theme() works", {
  pkg <- local_pkgdown_site()
  expect_equal(check_bslib_theme("default", pkg, bs_version = 4), "default")
  expect_equal(check_bslib_theme("lux", pkg, bs_version = 4), "lux")
  expect_snapshot(error = TRUE, {
    check_bslib_theme("paper", pkg, bs_version = 4)
  })
})

test_that("get_bslib_theme() works with template.bslib.preset", {
  pkg <- local_pkgdown_site(
    meta = list(
      template = list(bslib = list(preset = "shiny"), bootstrap = 5)
    )
  )
  expect_equal(get_bslib_theme(pkg), "shiny")
  expect_no_error(bs_theme(pkg))

  pkg <- local_pkgdown_site(
    meta = list(
      template = list(bslib = list(preset = "lux"), bootstrap = 5)
    )
  )
  expect_equal(get_bslib_theme(pkg), "lux")
  expect_no_error(bs_theme(pkg))
})

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
