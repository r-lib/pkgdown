test_that("check_bootswatch_theme() works", {
  expect_snapshot_error(check_bootswatch_theme("paper", 4, list()))
  expect_null(check_bootswatch_theme(NULL, 4, list()))
  expect_null(check_bootswatch_theme("lux", 4, list()))
})
