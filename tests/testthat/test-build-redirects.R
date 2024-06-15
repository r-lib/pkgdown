test_that("build_redirect() works", {
  pkg <- list(
    src_path = withr::local_tempdir(),
    dst_path = withr::local_tempdir(),
    meta = list(url = "https://example.com"),
    prefix = "",
    bs_version = 5
  )
  pkg <- structure(pkg, class = "pkgdown")
  expect_snapshot(
    build_redirect(c("old.html", "new.html#section"), 1, pkg = pkg)
  )

  html <- xml2::read_html(path(pkg$dst_path, "old.html"))
  expect_equal(
    xpath_attr(html, "//link", "href"),
    "https://example.com/new.html#section"
  )
})

test_that("build_redirect() errors if one entry is not right.", {
  data_redirects_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    data_redirects(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_redirects_(redirects = "old.html")
    data_redirects_(redirects = list("old.html"))
  })
})

test_that("article_redirects() creates redirects for vignettes in vignettes/articles", {
  dir <- withr::local_tempdir()
  dir_create(path(dir, "vignettes", "articles"))
  file_create(path(dir, "vignettes", "articles", "test.Rmd"))

  pkg <- list(
    meta = list(url = "http://foo.com"),
    vignettes = package_vignettes(dir)
  )

  expect_equal(
    article_redirects(pkg),
    list(c("articles/articles/test.html", "articles/test.html"))
  )
})

# reference_redirects ----------------------------------------------------------

test_that("generates redirects only for non-name aliases", {
  pkg <- list(
    meta = list(url = "http://foo.com"),
    topics = list(
      alias = list("foo", c("bar", "baz")),
      name = c("foo", "bar"),
      file_out = c("foo.html", "bar.html")
    )
  )
  expect_equal(
    reference_redirects(pkg),
    list(c("reference/baz.html", "reference/bar.html"))
  )
})

test_that("doesn't generates redirect for aliases that can't be file names", {
  pkg <- list(
    meta = list(url = "http://foo.com"),
    topics = list(
      name = "bar",
      alias = list(c("bar", "baz", "[<-.baz")),
      file_out = "bar.html"
    )
  )
  expect_equal(
    reference_redirects(pkg),
    list(c("reference/baz.html", "reference/bar.html"))
  )
})

test_that("never redirects away from existing topic", {
  pkg <- list(
    meta = list(url = "http://foo.com"),
    topics = list(
      alias = list("foo", c("bar", "foo")),
      name = c("foo", "bar"),
      file_out = c("foo.html", "bar.html")
    )
  )
  expect_equal(
    reference_redirects(pkg),
    list()
  )
})

test_that("no redirects if no aliases", {
  pkg <- list(
    meta = list(url = "http://foo.com"),
    topics = list(
      alias = list(c("foo", "bar")),
      name = c("foo", "bar"),
      file_out = c("foo.html", "bar.html")
    )
  )
  expect_equal(reference_redirects(pkg), list())
})
