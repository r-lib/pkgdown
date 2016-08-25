context("to_html")

test_that("special characters are escaped", {
  out <- rd2html("a & b")
  expect_equal(out, "a &amp; b")
})

# Usage -------------------------------------------------------------------

test_that("S4 methods don't have extraneous quotes", {
  out <- rd2html("\\S4method{fun}{class}(x, y)")
  expect_equal(out, "fun(x, y)")
})
