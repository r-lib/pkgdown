test_that("check_yaml_has produces informative errors", {
  pkg <- local_pkgdown_site()

  expect_snapshot(error = TRUE, {
    check_yaml_has("x", where = "a", pkg = pkg)
    check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
  })
})
