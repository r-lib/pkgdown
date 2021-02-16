test_that("get_bs_version gives an informative error message", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$template$bootstrap <- 5
  expect_snapshot_error(get_bs_version(pkg))
})
