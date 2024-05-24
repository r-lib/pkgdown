test_that("missing template package yields custom error", {
  expect_snapshot(path_package_pkgdown("x", "missing", 3), error = TRUE)
})


test_that("out_of_date works as expected", {
  temp1 <- file_create(withr::local_tempfile())
  expect_true(out_of_date(temp1, "doesntexist"))
  expect_snapshot(out_of_date("doesntexist", temp1), error = TRUE)

  temp2 <- file_create(withr::local_tempfile())
  file_touch(temp2, Sys.time() + 10)

  expect_true(out_of_date(temp2, temp1))
  expect_false(out_of_date(temp1, temp2))
  expect_false(out_of_date(temp1, temp1))
})
