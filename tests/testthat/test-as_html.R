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

test_that("tabular converted to html", {
  table <- "\\tabular{ll}{a \\tab b \\cr}"
  expectation <- c("<table><tr><td>a </td>", "<td> b </td>", "</tr></table>")
  expect_equal(rd2html(table), expectation)
})

test_that("out is for raw html", {
  expect_equal(rd2html("\\out{<hr />}"), "<hr />")
})


# sexpr  ------------------------------------------------------------------

test_that("code inside Sexpr is evaluated", {
  scoped_package_context("pkgdown")
  scoped_file_context()

  expect_equal(rd2html("\\Sexpr{1 + 2}"), "3")
})

test_that("Sexpr can contain multiple expressions", {
  scoped_package_context("pkgdown")
  scoped_file_context()

  expect_equal(rd2html("\\Sexpr{a <- 1; a}"), "1")
})

test_that("Sexprs in file share environment", {
  scoped_package_context("pkgdown")
  scoped_file_context()

  expect_equal(rd2html("\\Sexpr{a <- 1}\\Sexpr{a}"), c("1", "1"))
})

test_that("Sexprs run from package root", {
  # Because paths are different during R CMD check
  skip_if_not(file_exists("../../DESCRIPTION"))

  scoped_package_context("pkgdown", src_path = "../..")
  scoped_file_context()

  # \packageTitle is built in macro that uses DESCRIPTION
  expect_equal(
    rd2html("\\packageTitle{pkgdown}"),
    "Make Static HTML Documentation for a Package"
  )
})

# links -------------------------------------------------------------------

test_that("href orders arguments correctly", {
   expect_equal(
     rd2html("\\href{http://a.com}{a}"),
     a("a", href = "http://a.com")
   )
})

test_that("can convert cross links to online documentation url", {
  scoped_package_context("test")

  expect_equal(
    rd2html("\\link[base]{library}"),
    a("library", href = "http://www.rdocumentation.org/packages/base/topics/library")
  )
})

test_that("can convert cross links to the same package (#242)", {
  scoped_package_context("mypkg", c(foo = "bar", baz = "baz"))
  scoped_file_context("baz")

  expect_equal(
    rd2html("\\link[mypkg]{foo}"),
    a("foo", href_topic_local("foo"))
  )
  expect_equal(
    rd2html("\\link[mypkg]{baz}"),
    "baz"
  )
})

test_that("can parse local links with topic!=label", {
  scoped_package_context("test", c(x = "y"))
  scoped_file_context("baz")

  expect_equal(
    rd2html("\\link[=x]{z}"),
    a("z", href_topic_local("x"))
  )
})

test_that("functions in other packages generates link to rdocumentation.org", {
  scoped_package_context("mypkg", c(x = "x", y = "y"))
  scoped_file_context("x")

  expect_equal(
    rd2html("\\link[stats:acf]{xyz}", current = current),
    a("xyz", href_topic_remote("acf", "stats"))
  )

  # Unless it's the current package
  expect_equal(
    rd2html("\\link[mypkg:y]{xyz}", current = current),
    a("xyz", href_topic_local("y"))
  )
})

test_that("link to non-existing functions return label", {
  scoped_package_context("mypkg")
  scoped_file_context("x")

  expect_equal(
    rd2html("\\link[xyzxyz:xyzxyz]{abc}", current = current),
    "abc"
  )
  expect_equal(
    rd2html("\\link[base:xyzxyz]{abc}", current = current),
    "abc"
  )
})

test_that("code blocks autolinked to vignettes", {
  scoped_package_context("test", article_index = c("abc" = "abc.html"))
  scoped_file_context(depth = 1L)

  expect_equal(
    rd2html("\\code{vignette('abc')}"),
    "<code><a href='../articles/abc.html'>vignette('abc')</a></code>"
  )
})

# Paragraphs --------------------------------------------------------------

test_that("empty lines break paragraphs", {
  expect_equal(
    flatten_para(rd_text("a\nb\n\nc")),
    "<p>a\nb</p>\n<p>c</p>"
  )
})

test_that("indented empty lines break paragraphs", {
  expect_equal(
    flatten_para(rd_text("a\nb\n  \nc")),
    "<p>a\nb</p>  \n<p>c</p>"
  )
})

test_that("block tags break paragraphs", {
  out <- flatten_para(rd_text("a\n\\itemize{\\item b}\nc"))
  expect_equal(out, "<p>a</p><ul>\n<li><p>b</p></li>\n</ul><p>c</p>")
})

test_that("inline tags + empty line breaks", {
  out <- flatten_para(rd_text("a\n\n\\code{b}"))
  expect_equal(out, "<p>a</p>\n<p><code>b</code></p>")
})

test_that("single item can have multiple paragraphs", {
  out <- flatten_para(rd_text("\\itemize{\\item a\n\nb}"))
  expect_equal(out, "<ul>\n<li><p>a</p>\n<p>b</p></li>\n</ul>\n")
})

test_that("nl after tag doesn't trigger paragraphs", {
  out <- flatten_para(rd_text("One \\code{}\nTwo"))
  expect_equal(out, "<p>One <code></code>\nTwo</p>")
})

test_that("cr generates line break", {
  out <- flatten_para(rd_text("a \\cr b"))
  expect_equal(out, "<p>a <br /> b</p>")
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


# Value blocks ------------------------------------------------------------

test_that("leading text parsed as paragraph", {
  expected <- "<p>text</p>\n<dt>x</dt><dd><p>y</p></dd>"

  value1 <- rd_text("\\value{\ntext\n\\item{x}{y}}", fragment = FALSE)
  expect_equal(as_data(value1[[1]])$contents, expected)

  value2 <- rd_text("\\value{text\\item{x}{y}}", fragment = FALSE)
  expect_equal(as_data(value2[[1]])$contents, expected)
})

test_that("leading text is optional", {
  value <- rd_text("\\value{\\item{x}{y}}", fragment = FALSE)
  expect_equal(as_data(value[[1]])$contents, "<dt>x</dt><dd><p>y</p></dd>")
})

test_that("items are optional", {
  value <- rd_text("\\value{text}", fragment = FALSE)
  expect_equal(as_data(value[[1]])$contents, "<p>text</p>")
})


# figures -----------------------------------------------------------------

test_that("figures are converted to img", {
  expect_equal(rd2html("\\figure{a}"), "<img src='figures/a' alt='' />")
  expect_equal(rd2html("\\figure{a}{b}"), "<img src='figures/a' alt='b' />")
  expect_equal(
    rd2html("\\figure{a}{options: height=1}"),
    "<img src='figures/a' height=1 />"
  )
})


# titles ------------------------------------------------------------------

test_that("multiline titles are collapsed", {
  rd <- rd_text("\\title{
    x
  }", fragment = FALSE)

  expect_equal(extract_title(rd), "x")
})

test_that("titles can contain other markup", {
  rd <- rd_text("\\title{\\strong{x}}", fragment = FALSE)
  expect_equal(extract_title(rd), "<strong>x</strong>")
})

test_that("titles don't get autolinked code", {
  rd <- rd_text("\\title{\\code{foo()}}", fragment = FALSE)
  expect_equal(extract_title(rd), "<code>foo()</code>")
})
