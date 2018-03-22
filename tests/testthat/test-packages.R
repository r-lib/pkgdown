context("packages")

test_that("extracts typical library()/require() calls", {
  expect_equal(extract_package_attach_(library("blah")), "blah")
  expect_equal(extract_package_attach_(library(blah)), "blah")
  expect_equal(extract_package_attach_(require("blah")), "blah")
  expect_equal(extract_package_attach_(require(blah)), "blah")
})

test_that("detects in nested code", {
  expect_equal(extract_package_attach_({
    library(a)
    {
      library(b)
      {
        library(c)
      }
    }
  }), c("a", "b", "c"))
})

test_that("detects with non-standard arg order", {
  expect_equal(extract_package_attach_(library(quiet = TRUE, pa = "a")), "a")
  expect_equal(extract_package_attach_(library(quiet = TRUE, a)), "a")
})

test_that("doesn't include if character.only = TRUE", {
  expect_equal(
    extract_package_attach_(library(x, character.only = TRUE)),
    character()
  )
})
