test_that("check_yaml_has produces informative errors", {
  pkg <- local_pkgdown_site()

  expect_snapshot(error = TRUE, {
    check_yaml_has("x", where = "a", pkg = pkg)
    check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
  })
})

test_that("config_pluck_yaml coerces empty value to character", {
  pkg <- local_pkgdown_site(meta = list(x = NULL))
  expect_equal(config_pluck_character(pkg, "x"), character())
  expect_equal(config_pluck_character(pkg, "y"), character())
})

test_that("config_pluck_yaml generates informative error", {
  pkg <- local_pkgdown_site(meta = list(x = 1))
  expect_snapshot(config_pluck_character(pkg, "x"), error = TRUE)
})