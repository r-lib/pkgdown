context("test-build-reference-index.R")

test_that("failure to select any topics returns no topics", {
  pkg <- test_path("assets/reference-no-matched-topics")
  expect_warning(
    data_reference_index(pkg),
    "No topics selected"
  )
})

test_that("selectors with no match generate a warning", {
  pkg <- test_path("assets/reference-unmatched-topics")
  expect_warning(
    data_reference_index(pkg),
    "topic must match a function or concept"
  )
})
