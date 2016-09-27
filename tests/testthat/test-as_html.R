context("as_html")

test_that("special characters are escaped", {
  out <- rd2html("a & b")
  expect_equal(out, "a &amp; b")
})

test_that("comments converted to html", {
  expect_equal(rd2html("a\n%b\nc"), c("a", "<!-- %b -->", "c"))
})

test_that("simple wrappers work as expected", {
  expect_equal(rd2html("\\strong{x}"), "<strong>x</strong>")
  expect_equal(rd2html("\\strong{\\emph{x}}"), "<strong><em>x</em></strong>")
})

test_that("simple replacements work as expected", {
  expect_equal(rd2html("\\ldots"), "&#8230;")
})

test_that("subsection generates h3", {
  expect_equal(rd2html("\\subsection{A}{B}"), c("<h3>A</h3>", "B"))
})

test_that("if generates html", {
  expect_equal(rd2html("\\if{html}{\\bold{a}}"), "<b>a</b>")
  expect_equal(rd2html("\\if{latex}{\\bold{a}}"), character())
})

test_that("ifelse generates html", {
  expect_equal(rd2html("\\ifelse{html}{\\bold{a}}{x}"), "<b>a</b>")
  expect_equal(rd2html("\\ifelse{latex}{x}{\\bold{a}}"), "<b>a</b>")
})

test_that("code inside Sexpr is evaluated", {
  expect_equal(rd2html("\\Sexpr{1 + 2}"), "3")
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
