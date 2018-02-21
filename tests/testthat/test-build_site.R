context("build_site")

test_that("can build package without any index/readme", {
  expect_output(
    build_site(test_path("site-empty"), fs::file_temp())
  )
})
