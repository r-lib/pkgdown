test_that("build_redirect() works", {
  pkg <- list(
    src_path = withr::local_tempdir(),
    dst_path = withr::local_tempdir(),
    meta = list(url = "https://example.com"),
    prefix = "",
    bs_version = 5
  )
  pkg <- structure(pkg, class = "pkgdown")
  build_redirect(c("old.html", "new.html#section"), 1, pkg = pkg)

  html <- xml2::read_html(path(pkg$dst_path, "old.html"))
  expect_equal(
    xpath_attr(html, "//link", "href"),
    "https://example.com/new.html#section"
  )
})

test_that("build_redirect() errors if one entry is not right.", {
  pkg <- list(
    src_path = withr::local_tempdir(),
    dst_path = withr::local_tempdir(),
    meta = list(url = "https://example.com"),
    prefix = "",
    bs_version = 5
  )
  pkg <- structure(pkg, class = "pkgdown")
  expect_snapshot_error(build_redirect(c("old.html"), 5, pkg = pkg))
})

test_that("article_redirects() creates redirects for vignettes in vignettes/articles", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, "vignettes", "articles"))
  file_create(path(dir, "vignettes", "articles", "test.Rmd"))

  pkg <- list(
    vignettes = package_vignettes(dir)
  )

  expect_equal(
    article_redirects(pkg),
    list(c("articles/articles/test.html", "articles/test.html"))
  )
})
