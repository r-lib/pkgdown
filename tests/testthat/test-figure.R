test_that("can override defaults in _pkgdown.yml", {
  skip_if_no_pandoc()
  skip_if_no_quarto()
  withr::local_temp_libpaths()

  pkg <- local_pkgdown_site(test_path("assets/figure"))
  suppressMessages(init_site(pkg))

  callr::rcmd("INSTALL", pkg$src_path, show = FALSE, fail_on_status = TRUE)

  suppressMessages(build_reference(pkg, devel = FALSE))
  img <- path_file(dir_ls(path(pkg$dst_path, "reference"), glob = "*.jpg"))
  expect_setequal(img, c("figure-1.jpg", "figure-2.jpg"))

  suppressMessages(build_articles(pkg))
  img <- path_file(dir_ls(
    path(pkg$dst_path, "articles"),
    glob = "*.jpg",
    recurse = TRUE
  ))
  expect_equal(img, "unnamed-chunk-1-1.jpg")
})
