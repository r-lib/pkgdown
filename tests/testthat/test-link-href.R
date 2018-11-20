context("test-link-href.R")

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

test_that("can link to functions in registered packages", {
  scoped_package_context("test")
  register_attached_packages("MASS")

  expect_equal(href_expr_(addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(addterm.default()), href_topic_remote("addterm", "MASS"))
})

test_that("can link to functions in base packages", {
  scoped_package_context("test")
  scoped_file_context() # package registry maintained on per-file basis

  expect_equal(href_expr_(library()), href_topic_remote("library", "base"))
  expect_equal(href_expr_(median()), href_topic_remote("median", "stats"))
})

test_that("links to home of re-exported functions", {
  # can't easily access exports in 3.1
  skip_if_not(getRversion() >= "3.2.0")

  scoped_package_context("pkgdown")
  expect_equal(href_expr_(addterm()), href_topic_remote("addterm", "MASS"))
})

test_that("fails gracely if can't find re-exported function", {
  skip_if_not(getRversion() >= "3.2.0")

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
  skip_on_cran()
  scoped_package_context("test")

  expect_equal(
    href_expr_(vignette("sha1", "digest")),
    "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )

  expect_equal(
    href_expr_(vignette(package = "digest", "sha1")),
    "https://cran.rstudio.com/web/packages/digest/vignettes/sha1.html"
  )

  expect_equal(
    href_expr_(vignette("highlight", "pkgdown")),
    "https://pkgdown.r-lib.org/articles/test/highlight.html"
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

test_that("trailing pieces of github URLs are stripped", {
  expect_equal(
    parse_github_link("https://github.com/simsem/semTools/wiki"),
    "https://github.com/simsem/semTools"
  )
  expect_equal(
    parse_github_link("https://github.com/r-lib/gh#readme"),
    "https://github.com/r-lib/gh"
  )
})

test_that("source links are valid github URLs", {
  expect_equal(
    github_source_links("https://github.com/tidyverse/reprex#readme", "NEWS.md"),
    "Source: <a href='https://github.com/tidyverse/reprex/blob/master/NEWS.md'><code>NEWS.md</code></a>"
  )
})

test_that("fail gracefully with non-working calls", {
  scoped_package_context("test")

  expect_equal(href_expr_(vignette()), NA_character_)
  expect_equal(href_expr_(vignette(package = package)), NA_character_)
  expect_equal(href_expr_(vignette(1, 2)), NA_character_)
  expect_equal(href_expr_(vignette(, )), NA_character_)
})

test_that("spurious functions are not linked (#889)", {
  scoped_package_context("test")

  expect_equal(href_expr_(Authors@R), NA_character_)
  expect_equal(href_expr_(content-home.html), NA_character_)
  expect_equal(href_expr_(toc: depth), NA_character_)
})
