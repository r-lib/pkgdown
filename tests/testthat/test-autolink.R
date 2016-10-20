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
