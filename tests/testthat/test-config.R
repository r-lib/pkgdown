
test_that("config_pluck_character coerces empty values to character", {
  pkg <- local_pkgdown_site(meta = list(x = NULL, y = list()))
  expect_equal(config_pluck_character(pkg, "x"), character())
  expect_equal(config_pluck_character(pkg, "y"), character())
  expect_equal(config_pluck_character(pkg, "z"), character())
})

test_that("config_pluck_character generates informative error", {
  pkg <- local_pkgdown_site(meta = list(x = 1))
  expect_snapshot(config_pluck_character(pkg, "x"), error = TRUE)
})

test_that("config_pluck_string generates informative error", {
  pkg <- local_pkgdown_site(meta = list(x = 1))
  expect_snapshot(config_pluck_string(pkg, "x"), error = TRUE)
})

# checkers --------------------------------------------------------------------

test_that("config_check_list() returns list if ok", {
  x <- list(x = 1, y = 2)
  expect_equal(config_check_list(x), x)
  expect_equal(config_check_list(x, has_names = "x"), x)
  expect_equal(config_check_list(x, has_names = c("x", "y")), x)
})

test_that("config_check_list gives informative errors", {
  # Avoid showing unneeded call details in snapshot
  pkg <- local_pkgdown_site()
  config_check_list_ <- function(...) {
    config_check_list(..., error_pkg = pkg, error_path = "path")
  }

  expect_snapshot(error = TRUE, {
    config_check_list_(1, has_names = "x")
    config_check_list_(list(x = 1, y = 1), has_names = c("y", "z"))
  })
})
