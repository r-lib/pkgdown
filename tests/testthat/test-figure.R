context("test-figure.R")

test_that("can override defaults in _pkgdown.yml", {
  figure <- test_path("figure")
  on.exit(clean_site(figure))

  expect_output(build_reference(figure))
  img <- path_file(dir_ls(path(figure, "docs", "reference"), glob = "*.jpg"))
  expect_setequal(img, c("figure-1.jpg", "figure-2.jpg"))

  expect_output(build_articles(figure))
  img <- path_file(dir_ls(path(figure, "docs", "articles"), glob = "*.jpg", recursive = TRUE))
  expect_equal(img, "unnamed-chunk-1-1.jpg")
})
