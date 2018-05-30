context("test-build-citation-authors.R")

# A CITATION file anywhere except in `inst/CITATION` is an R CMD check note
# so 'site-citation' is build-ignored, and so the tests must be skipped
# during R CMD check

test_that("UTF-8 encoding and `citation(auto = meta) can be read` (#416, #493)", {
  path <- test_path("assets/site-citation/encoding-UTF-8")
  skip_if_not(dir_exists(path)[[1]])

  cit <- read_citation(path)
  expect_is(cit, "citation")
})

test_that("latin1 encoding and `citation(auto = meta) can be read` (#689)", {
  path <- test_path("assets/site-citation/encoding-latin1")
  skip_if_not(dir_exists(path)[[1]])

  cit <- read_citation(path)
  expect_is(cit, "citation")
})

test_that("create_meta can read DESCRIPTION with an Encoding", {
  path <- test_path("assets/site-citation/encoding-UTF-8")
  skip_if_not(dir_exists(path)[[1]])

  meta <- create_meta(path)
  expect_type(meta, "list")
  expect_equal(meta$`Authors@R`, 'person(\"Florian\", \"Privé\")')
})
