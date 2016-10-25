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

context("remote links")

test_that("can construct external link for package/topic", {
  expect_equal(link_remote(label="library", topic="library", package="base"),
               "<a href='http://www.rdocumentation.org/packages/base/topics/library'>library</a>")
})
