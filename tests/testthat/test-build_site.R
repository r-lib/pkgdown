context("test-build_site.R")

test_that("can build package without any index/readme", {
  pkg <- test_path("assets/site-empty")
  on.exit(clean_site(pkg))

  expect_output(build_site(pkg))
})
