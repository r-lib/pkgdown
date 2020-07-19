test_that("render_rmarkdown copies image files in subdirectories", {
  skip_if_no_pandoc()
  tmp <- dir_create(file_temp())
  pkg <- list(src_path = test_path("."), dst_path = tmp)

  expect_output(
    render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
  )
  expect_equal(
    path_rel(dir_ls(tmp, type = "file", recurse = TRUE), tmp),
    c("open-graph/logo.png", "test.html")
  )
})

test_that("render_rmarkdown yields useful error", {
  skip_if_no_pandoc()
  tmp <- dir_create(file_temp())
  pkg <- list(src_path = test_path("."), dst_path = tmp)

  verify_output(test_path("test-rmarkown-error.txt"), {
    render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html")
  })
})
