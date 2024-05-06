test_that("config_check_list() returns list if ok", {
  x <- list(x = 1, y = 2)
  expect_equal(config_check_list(x), x)
  expect_equal(config_check_list(x, "x"), x)
  expect_equal(config_check_list(x, c("x", "y")), x)
})

test_that("config_check_list gives informative errors", {
  pkg <- local_pkgdown_site()

  expect_snapshot(error = TRUE, {
    config_check_list(
      1,
      "x",
      error_pkg = pkg,
      error_path = "path"
    )
   
    config_check_list(
      list(x = 1, y = 1),
      c("y", "z"),
      error_pkg = pkg,
      error_path = "path"
    )
  })
}) 

test_that("config_pluck_character coerces empty values to character", {
  pkg <- local_pkgdown_site(meta = list(x = NULL))
  expect_equal(config_pluck_character(pkg, "x"), character())
  expect_equal(config_pluck_character(pkg, "y"), character())
})

test_that("config_pluck_character generates informative error", {
  pkg <- local_pkgdown_site(meta = list(x = 1))
  expect_snapshot(config_pluck_character(pkg, "x"), error = TRUE)
})