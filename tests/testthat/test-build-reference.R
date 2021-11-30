test_that("parse failures include file name", {
  skip_if_not_installed("rlang", "0.99")
  pkg <- local_pkgdown_site("assets/reference-fail")
  expect_snapshot(build_reference(pkg), error = TRUE)
})

test_that("examples_env runs pre and post code", {
  dst_path <- withr::local_tempdir()
  dir_create(path(dst_path, "reference"))

  pkg <- list(
    package = "test",
    src_path = test_path("assets/reference-pre-post"),
    dst_path = dst_path
  )

  env <- local(examples_env(pkg))
  expect_equal(env$a, 2)
})

test_that("examples_env sets width", {
  pkg <- local_pkgdown_site(test_path("assets/reference"), "
    code:
      width: 50
  ")

  examples_env(pkg)
  expect_equal(getOption("width"), 50)
})
