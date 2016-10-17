context("autolink")

test_that("can find alias from fun call", {
  expect_equal(find_alias_fun(quote(fun())), "fun")
  expect_equal(find_alias_fun(quote(fun)), "fun")
})

test_that("can find alias from help usage", {
  expect_equal(find_alias_help(quote(?abc)), "abc")
  expect_equal(find_alias_help(quote(?"a-b-c")), "a-b-c")
  expect_equal(find_alias_help(quote(package?abc)), "abc-package")
})
