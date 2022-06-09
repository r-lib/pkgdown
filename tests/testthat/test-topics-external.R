test_that("can get info about external function", {
  expect_snapshot(str(ext_topics("base::mean")))
})

test_that("fails if documentation not available", {
  expect_snapshot(ext_topics("base::doesntexist"), error = TRUE)
})
