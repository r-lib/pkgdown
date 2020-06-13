context("test-utils.R")

test_that("pkgdown.internet can be set and read", {
  options(pkgdown.internet = FALSE)
  expect_false(has_internet())
})

test_that("cran_unquote works", {
  expect_equal(cran_unquote("Quoting is CRAN's thing."),
               "Quoting is CRAN's thing.")
  expect_equal(cran_unquote("'R-hub' is great!"),
               "R-hub is great!")
  expect_equal(cran_unquote("From 'README' to 'html' with 'pkgdown'"),
               "From README to html with pkgdown")
})

