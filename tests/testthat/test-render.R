test_that("check_bootswatch_theme() works", {
  expect_equal(check_bootswatch_theme("_default", 4, list()), NULL)
  expect_equal(check_bootswatch_theme("lux", 4, list()), "lux")
  expect_snapshot_error(check_bootswatch_theme("paper", 4, list()))
})

