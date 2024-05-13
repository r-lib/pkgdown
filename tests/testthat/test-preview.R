test_that("checks its inputs", {
  pkg <- local_pkgdown_site(test_path("assets/articles-images"))

  expect_snapshot(error = TRUE, {
    preview_site(pkg, path = 1)
    preview_site(pkg, preview = 1)
  })
})
