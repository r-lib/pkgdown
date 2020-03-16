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

test_that("repo_source() truncates automatically", {
  pkg <- list(github_url = "https://github.com/r-lib/pkgdown")

  verify_output(test_path("test-github-source.txt"), {
    cat(repo_source(pkg, "a"))
    cat(repo_source(pkg, letters[1:10]))
  })
})
