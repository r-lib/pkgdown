context("build_site")

test_that("can build package without any index/readme", {
  pkg <- test_path("site-empty")
  on.exit(clean_site(pkg))

  expect_output(build_site(pkg))
})
