context("usage")

test_that("S4 methods don't have extraneous quotes", {
  out <- rd2html("\\S4method{fun}{class}(x, y)")
  expect_equal(out, "fun(x, y)")
})
