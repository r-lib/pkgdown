context("test-github")

test_that("authors must have leading whitespace", {
  pkg <- list(url = "")
  expect_equal(
    add_github_links("x@y", pkg), "x@y"
  )
  expect_equal(
    add_github_links("@y", pkg),
    "<a href='https://github.com/y'>@y</a>"
  )
  expect_equal(
    add_github_links(" @y", pkg),
    " <a href='https://github.com/y'>@y</a>"
  )
})

test_that("or an open parenthesis", {
  pkg <- list(url = "")
  expect_equal(
    add_github_links("(@y)", pkg),
    "(<a href='https://github.com/y'>@y</a>)"
  )
})
