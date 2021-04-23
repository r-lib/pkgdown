test_that("build_redirect() works", {
  pkg <- list(
    src_path = withr::local_tempdir(),
    dst_path = withr::local_tempdir(),
    meta = list(url = "https://example.com"),
    development = list(in_dev = FALSE),
    bs_version = 4
  )
  pkg <- structure(pkg, class = "pkgdown")
  build_redirect(c("old.html", "new.html#section"), pkg = pkg, paths = "new.html")
  expect_snapshot(
    cat(read_lines(file.path(pkg$dst_path, "old.html")))
  )

})
