context("test-build-reference-index.R")

test_that("a failure to select any topics returns all topics", {
  pkg <- test_path("assets/reference-unmatched-topics")
  expect_warning(
    build_reference_index(pkg),
    "Failed to select a topic"
  )
})
