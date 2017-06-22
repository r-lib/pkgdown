context("build_site")


test_that("can build package without any index/readme", {
  expect_error(
    build_site(test_path("site-empty"), tempdir()),
    NA
  )
})
