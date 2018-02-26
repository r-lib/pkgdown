context("build-citation-authors.R")

test_that("CITATION with non-ASCII author and `citation(auto = meta) can be read` (#416, #493)", {
  path <- test_path('site-citation')
  cit <- read_citation(path)
  expect_is(cit, 'citation')
})

test_that("create_meta can read DESCRIPTION with an Encoding", {
  meta <- create_meta(test_path('site-citation'))
  expect_is(meta, "list")
  expect_equal(meta$`Authors@R`, 'person(\"Florian\", \"Privé\")')
})
