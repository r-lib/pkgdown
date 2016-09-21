context("to_html")

test_that("special characters are escaped", {
  out <- rd2html("a & b")
  expect_equal(out, "a &amp; b")
})

# Usage -------------------------------------------------------------------

test_that("S4 methods gets comment", {
  out <- rd2html("\\S4method{fun}{class}(x, y)", TRUE)
  expect_equal(out[1], "# S4 method for class")
  expect_equal(out[2], "fun(x, y)")
})

test_that("S3 methods gets comment", {
  out <- rd2html("\\S3method{fun}{class}(x, y)", TRUE)
  expect_equal(out[1], "# S3 method for class")
  expect_equal(out[2], "fun(x, y)")
})


test_that("eqn", {
  out <- rd2html(" \\eqn{\\alpha}{alpha}", TRUE, pkg=list(mathjax = TRUE))
  expect_equal(out, "$\\alpha$")
  out <- rd2html(" \\eqn{\\alpha}{alpha}", TRUE, pkg=list(mathjax = FALSE))
  expect_equal(out, "<code class = 'eq'>alpha</code>")
  out <- rd2html(" \\eqn{x}", TRUE, pkg=list(mathjax = TRUE))
  expect_equal(out, "$x$")
  out <- rd2html(" \\eqn{x}", TRUE, pkg=list(mathjax = FALSE))
  expect_equal(out, "<code class = 'eq'>x</code>")
})

test_that("deqn", {
  out <- rd2html(" \\deqn{\\alpha}{alpha}", TRUE, pkg=list(mathjax = TRUE))
  expect_equal(out, "$$\\alpha$$")
  out <- rd2html(" \\deqn{\\alpha}{alpha}", TRUE, pkg=list(mathjax = FALSE))
  expect_equal(out, "<pre class = 'eq'>alpha</pre>")
  out <- rd2html(" \\deqn{x}", TRUE, pkg=list(mathjax = TRUE))
  expect_equal(out, "$$x$$")
  out <- rd2html(" \\deqn{x}", TRUE, pkg=list(mathjax = FALSE))
  expect_equal(out, "<pre class = 'eq'>x</pre>")
})
