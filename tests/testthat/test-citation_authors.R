context("build citation/authors")

test_that("citations are read with explicit encoding (#416)", {
  path <- test_path('data-citation/encoding')
  cit <- read_citation(path, encoding = 'UTF-8')
  expect_is(cit, 'citation')
})

test_that("citation(auto = meta) does not error (#493)", {
  path <- test_path('data-citation/auto-meta')
  cit <- read_citation(path, encoding = 'UTF-8')
  expect_is(cit, 'citation')
})
