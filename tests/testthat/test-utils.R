context("utils")

test_that("find_reexport_source", {
  ns <- asNamespace("pkgdown")
  expect_equal(
    find_reexport_source(rlang::ns_env_name, ns, "ns_env_name"),
    "rlang"
  )
})

test_that("find_reexport_source_from_imports", {
  ns <- asNamespace("pkgdown")
  expect_equal(
    find_reexport_source_from_imports(ns, "ns_env_name"),
    "rlang"
  )
  expect_equal(
    find_reexport_source_from_imports(ns, "R6Class"),
    "R6"
  )
})
