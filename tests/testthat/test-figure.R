context("test-figure.R")

test_that("can override defaults in _pkgdown.yml", {
  skip_if_no_pandoc()

  figure <- test_path("assets/figure")
  on.exit(clean_site(figure))

  callr::rcmd("INSTALL", figure, show = FALSE, fail_on_status = TRUE)

  expect_output(build_reference(figure, devel = FALSE))
  img <- path_file(dir_ls(path(figure, "docs", "reference"), glob = "*.jpg"))
  expect_setequal(img, c("figure-1.jpg", "figure-2.jpg"))

  expect_output(build_articles(figure))
  img <- path_file(dir_ls(path(figure, "docs", "articles"), glob = "*.jpg", recurse = TRUE))
  expect_equal(img, "unnamed-chunk-1-1.jpg")
})
