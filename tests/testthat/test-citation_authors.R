context("build citation/authors")

test_that("citations are read with explicit encoding (#416)", {
  path <- test_path('data-citation')
  cit <- read_citation(path, encoding = 'UTF-8')
  expect_is(cit, 'citation')
})
