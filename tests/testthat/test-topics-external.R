test_that("can get info about external function", {
  expect_snapshot(str(ext_topics("base::mean")))

  # and column names match
  pkg <- as_pkgdown(test_path("assets/reference"))
  expect_equal(names(ext_topics("base::mean")), names(pkg$topics))
})

test_that("fails if documentation not available", {
  expect_snapshot(ext_topics("base::doesntexist"), error = TRUE)
})
