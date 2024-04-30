test_that("missing template package yields custom error", {
  expect_snapshot(path_package_pkgdown("x", "missing", 3), error = TRUE)
})
