context("href")

test_that("can link function calls", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("test")

  expect_equal(href_expr_(foo()), "bar.html")
  expect_equal(href_expr_(foo(1, 2, 3)), "bar.html")
})

test_that("respects href_topic_local args", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context()
  expect_equal(href_expr_(foo()), "reference/bar.html")

  scoped_file_context("bar")
  expect_equal(href_expr_(foo()), NA_character_)
})

test_that("can link remote objects", {
  scoped_package_context("test")

  expect_equal(href_expr_(MASS::abbey), href_topic_remote("abbey", "MASS"))
  expect_equal(href_expr_(MASS::addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(MASS::addterm.default()), href_topic_remote("addterm", "MASS"))

  # Doesn't exist
  expect_equal(href_expr_(MASS::blah), NA_character_)
})

test_that("links to home of re-exported functions", {
  scoped_package_context("pkgdown")
  expect_equal(href_expr_(addterm()), href_topic_remote("addterm", "MASS"))
})

test_that("fails gracely if can't find re-exported function", {
  scoped_package_context("pkgdown", c(foo = "reexports"))
  expect_equal(href_expr_(foo()), NA_character_)
})

test_that("can link to remote pkgdown sites", {
  scoped_package_context("test", c(foo = "bar"))

  expect_equal(href_expr_(pkgdown::add_slug), href_topic_remote("pkgdown", "add_slug"))
  expect_equal(href_expr_(pkgdown::add_slug(1)), href_topic_remote("pkgdown", "add_slug"))
})

test_that("or local sites, if registered", {
  scoped_package_context("pkgdown", local_packages = c("MASS" = "MASS"))
  expect_equal(href_expr_(MASS::abbey), "MASS/reference/abbey.html")
})

test_that("only links bare symbols if requested", {
  scoped_package_context("test", c(foo = "bar"))
  scoped_file_context("baz")

  expect_equal(href_expr_(foo), NA_character_)
  expect_equal(href_expr_(foo, bare_symbol = TRUE), "bar.html")
})


# help --------------------------------------------------------------------

test_that("can link ? calls", {
  scoped_package_context("test", c(foo = "foo", "foo-package" = "foo-package"))
  scoped_file_context("bar")

  expect_equal(href_expr_(?foo), "foo.html")
  expect_equal(href_expr_(?"foo"), "foo.html")
  expect_equal(href_expr_(test::foo), "foo.html")
  expect_equal(href_expr_(package?foo), "foo-package.html")
})


# vignette ----------------------------------------------------------------

test_that("can link to local articles", {
  scoped_package_context("test", article_index = c(x = "y.html"))
  scoped_file_context(depth = 0)

  expect_equal(href_expr_(vignette("x")), "articles/y.html")
  expect_equal(href_expr_(vignette("x", package = "test")), "articles/y.html")
  expect_equal(href_expr_(vignette("y")), NA_character_)
})

test_that("can link to remote articles", {
  scoped_package_context("test")

  expect_equal(
    href_expr_(vignette("sha1", "digest")),
     "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )

  expect_equal(
    href_expr_(vignette("highlight", "pkgdown")),
    "http://pkgdown.r-lib.org/articles/test/highlight.html"
  )
})

test_that("or local sites, if registered", {
  scoped_package_context("pkgdown", local_packages = c("digest" = "digest"))
  expect_equal(href_expr_(vignette("sha1", "digest")), "digest/articles/sha1.html")
})

test_that("github_source returns (possibly many) URLs", {
  base <- "https://github.com/r-lib/pkgdown"
  expect_equal(
    github_source(base, c("http://example.com", "R/example.R")),
    c(
      "http://example.com", # Already is a URL, so not modified
      "https://github.com/r-lib/pkgdown/blob/master/R/example.R"
    )
  )
})
