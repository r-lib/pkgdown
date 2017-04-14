context("autolink")

test_that("can find alias from fun call", {
  expect_equal(find_alias(quote(fun())), "fun")
  expect_equal(find_alias(quote(fun(a))), "fun")
})

test_that("only matches bare names when !strict", {
  expect_equal(find_alias(quote(fun), strict = TRUE), NULL)
  expect_equal(find_alias(quote(fun), strict = FALSE), "fun")
})

test_that("can find alias from help usage", {
  expect_equal(find_alias(quote(?abc)), "abc")
  expect_equal(find_alias(quote(?"a-b-c")), "a-b-c")
  expect_equal(find_alias(quote(package?abc)), "abc-package")
})


# remote links ------------------------------------------------------------

test_that("can construct external link for package/topic", {
  expect_equal(
    link_remote(label = "library", topic = "library", package = "base"),
    "<a href='http://www.rdocumentation.org/packages/base/topics/library'>library</a>"
  )

  # note difference beween required topic and the label to be read by user
  # see https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Cross_002dreferences
  expect_equal(
    link_remote(label = "terms", topic = "terms.object", package = "stats"),
    "<a href='http://www.rdocumentation.org/packages/stats/topics/terms.object'>terms</a>"
  )
})

# calls ---------------------------------------------------------------

test_that("can link to vignette", {
  expect_equal(
    autolink_call("vignette('x')"),
    "<a href='../articles/x.html'>vignette('x')</a>"
  )
})

test_that("vignettes don't link if there's a package argument", {
  text <- "vignette('x', package = 'y')"
  expect_equal(autolink_call(text), NA_character_)
})
