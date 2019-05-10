context("test-build_article.R")

test_that("render_rmarkdown copies image files in subdirectories", {
  skip_if_no_pandoc()

  tmp <- tempfile()
  expect_output(
    render_rmarkdown(
      list(src_path = test_path(), dst_path = tmp),
      "assets/vignette-with-img.Rmd",
      "assets/articles/vignette-with-img.html"
    )
  )
  expect_equal(
    path_rel(dir_ls(tmp, type = "file", recurse = TRUE), tmp),
    c(
      "assets/articles/open-graph/logo.png",
      "assets/articles/vignette-with-img.html"
    )
  )
})
