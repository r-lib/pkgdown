context("util")

test_that("rel_path() handles an absolute path", {
  expect_equal(rel_path("\\drive\folder"), "\\drive\folder")
  expect_equal(rel_path("/folder"), "/folder")
  expect_equal(rel_path("C:\\folder"), "C:\\folder")
  expect_equal(rel_path("C:/folder"), "C:/folder")
})

test_that("rel_path() returns a relative path (#409)", {
  expect_equal(rel_path("a/b", "here"), "here/a/b")
  expect_equal(rel_path("a/b", "."), "a/b")

  # The path here is absolute so nothing happens
  expect_equal(rel_path("/a/b", "here"), "/a/b")
  expect_equal(rel_path("/a/b", "."), "/a/b")
})
