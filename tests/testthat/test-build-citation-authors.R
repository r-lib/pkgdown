context("build-citation-authors.R")

# A CITATION file anywhere except in `inst/CITATION` is an R CMD check note
# so 'site-citation' is build-ignored, and so the tests must be skipped
# during R CMD check

test_that("CITATION with non-ASCII author and `citation(auto = meta) can be read` (#416, #493)", {
  path <- test_path('site-citation')
  skip_if_not(dir_exists(path)[[1]])

  cit <- read_citation(path)
  expect_is(cit, 'citation')
})

test_that("create_meta can read DESCRIPTION with an Encoding", {
  path <- test_path('site-citation')
  skip_if_not(dir_exists(path)[[1]])

  meta <- create_meta(path)
  expect_type(meta, "list")
  expect_equal(meta$`Authors@R`, 'person(\"Florian\", \"Privé\")')
})
