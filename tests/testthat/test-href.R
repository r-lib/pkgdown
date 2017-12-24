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

test_that("can link to remote pkgdown sites", {
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
  expect_equal(href_expr_(package?foo), "foo-package.html")
})


# vignette ----------------------------------------------------------------

test_that("can link to local articles", {
  scoped_package_context("test", article_index = c(x = "y.html"))
  scoped_file_context(depth = 0)

  expect_equal(href_expr_(vignette("x")), "articles/y.html")
  expect_equal(href_expr_(vignette("y")), NA_character_)
})

test_that("can link to remote articles", {
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
