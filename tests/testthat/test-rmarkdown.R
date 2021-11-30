test_that("render_rmarkdown copies image files in subdirectories", {
  skip_if_no_pandoc()
  tmp <- dir_create(file_temp())
  pkg <- list(src_path = test_path("."), dst_path = tmp, bs_version = 3)

  expect_output(
    render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
  )
  expect_equal(
    as.character(path_rel(dir_ls(tmp, type = "file", recurse = TRUE), tmp)),
    c("open-graph/logo.png", "test.html")
  )
})

test_that("render_rmarkdown yields useful error", {
  skip_if_not_installed("rlang", "0.99")
  skip_if_no_pandoc()
  tmp <- dir_create(file_temp())
  pkg <- list(src_path = test_path("."), dst_path = tmp, bs_version = 3)

  expect_snapshot(error = TRUE, {
    render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html")
  })
})

test_that("render_rmarkdown styles ANSI escapes", {
  skip_if_no_pandoc()
  tmp <- dir_create(file_temp())
  pkg <- list(src_path = test_path("."), dst_path = tmp, bs_version = 5)

  expect_output({
    path <- render_rmarkdown(pkg,
      input = "assets/vignette-with-crayon.Rmd",
      output = "test.html"
    )
  })
  html <- xml2::read_html(path)
  expect_snapshot_output(xpath_xml(html, ".//code//span[@class='co']"))
})
