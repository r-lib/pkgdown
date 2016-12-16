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

test_that("can convert cross links to online documentation url", {
  expect_equal(
    rd2html("\\link[base]{library}", current = new_current("library", "pkg.name")),
    link_remote(label = "library", topic = "library", package = "base")
  )
})

test_that("can convert cross links to the same package (#242)", {
  pkgdownindex = list(
    name = "build_site",
    alias = list(build_site.Rd = "build_site")
  )
  current <- new_current("library", "pkg.name")
  expect_equal(
    rd2html("\\link[pkg.name]{library}", index = pkgdownindex, current = current),
    link_local(label = "library", topic = "library", index = pkgdownindex, current = current)
  )
})

test_that("can parse local links with topic!=label", {
  pkgdownindex = list(
    name = "build_site",
    alias = list(build_site.Rd = "build_site")
  )
  expect_equal(
    rd2html("\\link[=build_site]{build_site function}", index = pkgdownindex),
    "<a href='build_site.html'>build_site function</a>"
  )
})


# Usage -------------------------------------------------------------------

test_that("S4 methods gets comment", {
  out <- rd2html("\\S4method{fun}{class}(x, y)")
  expect_equal(out[1], "# S4 method for class")
  expect_equal(out[2], "fun(x, y)")
})

test_that("S3 methods gets comment", {
  out <- rd2html("\\S3method{fun}{class}(x, y)")
  expect_equal(out[1], "# S3 method for class")
  expect_equal(out[2], "fun(x, y)")
})


test_that("eqn", {
  out <- rd2html(" \\eqn{\\alpha}{alpha}")
  expect_equal(out, "\\(\\alpha\\)")
  out <- rd2html(" \\eqn{\\alpha}{alpha}", mathjax = FALSE)
  expect_equal(out, "<code class = 'eq'>alpha</code>")
  out <- rd2html(" \\eqn{x}")
  expect_equal(out, "\\(x\\)")
  out <- rd2html(" \\eqn{x}", mathjax = FALSE)
  expect_equal(out, "<code class = 'eq'>x</code>")
})

test_that("deqn", {
  out <- rd2html(" \\deqn{\\alpha}{alpha}")
  expect_equal(out, "$$\\alpha$$")
  out <- rd2html(" \\deqn{\\alpha}{alpha}", mathjax = FALSE)
  expect_equal(out, "<pre class = 'eq'>alpha</pre>")
  out <- rd2html(" \\deqn{x}")
  expect_equal(out, "$$x$$")
  out <- rd2html(" \\deqn{x}", mathjax = FALSE)
  expect_equal(out, "<pre class = 'eq'>x</pre>")
})
