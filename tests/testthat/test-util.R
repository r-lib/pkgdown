context("util")

test_that("rel_path() handles an absolute path", {
  expect_equal(rel_path("\\drive\folder"), "\\drive\folder", windows = FALSE)
  expect_equal(rel_path("\\drive\folder"), "\\drive\folder", windows = TRUE)

  expect_equal(rel_path("/folder"), "/folder", windows = FALSE)
  expect_equal(rel_path("/folder"), "/folder", windows = TRUE)

  expect_equal(rel_path("C:\\folder"), "C:\\folder", windows = FALSE)
  expect_equal(rel_path("C:\\folder"), "C:\\folder", windows = TRUE)

  expect_equal(rel_path("C:/folder"), "C:/folder", windows = FALSE)
  expect_equal(rel_path("C:/folder"), "C:/folder", windows = TRUE)
})

test_that("rel_path() returns a relative path (#409)", {
  skip_on_os("windows")
  expect_equal(rel_path("a/b", "here", windows = FALSE), "here/a/b")
  expect_equal(rel_path("a/b", ".", windows = FALSE), "a/b")
})

test_that("rel_path() for Windows compares strings to find path (#409)", {
  expect_equal(rel_path("a/b", "here", windows = TRUE), "here/a/b")
  expect_equal(rel_path("a/b", ".", windows = TRUE), "a/b")
})

