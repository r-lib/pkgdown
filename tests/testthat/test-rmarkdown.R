context("build_article")

test_that("render_rmarkdown copies image files in subdirectories", {
  tmp <- tempfile()
  expect_output(
    render_rmarkdown(
      list(src_path = test_path(), dst_path = tmp),
      "vignette-with-img.Rmd",
      "articles/vignette-with-img.html"
    )
  )
  expect_identical(
    dir(tmp, recursive = TRUE),
    c("articles/open-graph/logo.png", "articles/vignette-with-img.html")
  )
})
