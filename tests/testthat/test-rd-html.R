context("test-rd-html.R")

test_that("special characters are escaped", {
  out <- rd2html("a & b")
  expect_equal(out, "a &amp; b")
})

test_that("simple tags translated to known good values", {
  verify_output(test_path("test-rd-html.txt"), {
    "# Simple insertions"
    rd2html("\\ldots")
    rd2html("\\dots")
    rd2html("\\R")
    rd2html("\\cr")

    "# Lists"
    rd2html("\\itemize{\\item a}")
    rd2html("\\enumerate{\\item a}")

    "# Links"
    rd2html("\\href{http://bar.com}{BAR}")
    rd2html("\\email{foo@bar.com}")
    rd2html("\\url{http://bar.com}")

    "Macros"
    rd2html("\\newcommand{\\froofy}{'froofy'} \\froofy{}")
    rd2html("\\renewcommand{\\froofy}{'froofy'} \\froofy{}")
  })
})

test_that("comments converted to html", {
  expect_equal(rd2html("a\n%b\nc"), c("a", "<!-- %b -->", "c"))
})

test_that("simple wrappers work as expected", {
  expect_equal(rd2html("\\strong{x}"), "<strong>x</strong>")
  expect_equal(rd2html("\\strong{\\emph{x}}"), "<strong><em>x</em></strong>")
})

test_that("subsection generates h3", {
  expect_equal(rd2html("\\subsection{A}{B}"), c("<h3>A</h3>", "<p>B</p>"))
})
test_that("subsection generates h3", {
  expect_equal(rd2html("\\subsection{A}{
    p1

    p2
  }"), c("<h3>A</h3>", "<p>p1</p>", "<p>p2</p>"))
})

test_that("if generates html", {
  expect_equal(rd2html("\\if{html}{\\bold{a}}"), "<b>a</b>")
  expect_equal(rd2html("\\if{latex}{\\bold{a}}"), character())
})

test_that("ifelse generates html", {
  expect_equal(rd2html("\\ifelse{html}{\\bold{a}}{x}"), "<b>a</b>")
  expect_equal(rd2html("\\ifelse{latex}{x}{\\bold{a}}"), "<b>a</b>")
})

test_that("out is for raw html", {
  expect_equal(rd2html("\\out{<hr />}"), "<hr />")
})


# tables ------------------------------------------------------------------

test_that("tabular genereates complete table html", {
  table <- "\\tabular{ll}{a \\tab b \\cr}"
  expectation <- c("<table class='table'>", "<tr><td>a</td><td>b</td></tr>", "</table>")
  expect_equal(rd2html(table), expectation)
})

test_that("internal \\crs are stripped", {
  table <- "\\tabular{l}{a \\cr b \\cr c \\cr}"
  expectation <- c("<table class='table'>", "<tr><td>a</td></tr>", "<tr><td>b</td></tr>", "<tr><td>c</td></tr>", "</table>")
  expect_equal(rd2html(table), expectation)
})

test_that("can convert single row", {
  expect_equal(
    rd2html("\\tabular{lll}{A \\tab B \\tab C \\cr}")[[2]],
    "<tr><td>A</td><td>B</td><td>C</td></tr>"
  )
})


test_that("don't need internal whitespace", {
  expect_equal(
    rd2html("\\tabular{lll}{\\tab\\tab C\\cr}")[[2]],
    "<tr><td></td><td></td><td>C</td></tr>"
  )
  expect_equal(
    rd2html("\\tabular{lll}{\\tab B \\tab\\cr}")[[2]],
    "<tr><td></td><td>B</td><td></td></tr>"
  )
  expect_equal(
    rd2html("\\tabular{lll}{A\\tab\\tab\\cr}")[[2]],
    "<tr><td>A</td><td></td><td></td></tr>"
  )

  expect_equal(
    rd2html("\\tabular{lll}{\\tab\\tab\\cr}")[[2]],
    "<tr><td></td><td></td><td></td></tr>"
  )
})

test_that("can skip trailing \\cr", {
  expect_equal(
    rd2html("\\tabular{lll}{A \\tab B \\tab C}")[[2]],
    "<tr><td>A</td><td>B</td><td>C</td></tr>"
  )
})

test_that("code blocks in tables render (#978)", {
  expect_equal(
    rd2html('\\tabular{ll}{a \\tab \\code{b} \\cr foo \\tab bar}')[[2]],
    "<tr><td>a</td><td><code>b</code></td></tr>"
  )
})

test_that("tables with tailing \n (#978)", {
  expect_equal(
    rd2html('
      \\tabular{ll}{
        a   \\tab     \\cr
        foo \\tab bar
      }
    ')[[2]],
    "<tr><td>a</td><td></td></tr>"
  )
})

# sexpr  ------------------------------------------------------------------

test_that("code inside Sexpr is evaluated", {
  local_context_eval()
  expect_equal(rd2html("\\Sexpr{1 + 2}"), "3")
})

test_that("can control \\Sexpr output", {
  local_context_eval()
  expect_equal(rd2html("\\Sexpr[results=hide]{1}"), character())
  expect_equal(rd2html("\\Sexpr[results=text]{1}"), "1")
  expect_equal(rd2html("\\Sexpr[results=rd]{\"\\\\\\emph{x}\"}"), "<em>x</em>")
})

test_that("Sexpr can contain multiple expressions", {
  local_context_eval()
  expect_equal(rd2html("\\Sexpr{a <- 1; a}"), "1")
})

test_that("Sexprs with multiple args are parsed", {
  local_context_eval()
  expect_equal(rd2html("\\Sexpr[results=hide,stage=build]{1}"), character())
})

test_that("Sexprs with multiple args are parsed", {
  local_context_eval()
  expect_error(rd2html("\\Sexpr[results=verbatim]{1}"), "not yet supported")
})

test_that("Sexprs in file share environment", {
  local_context_eval()
  expect_equal(rd2html("\\Sexpr{x <- 1}\\Sexpr{x}"), c("1", "1"))

  local_context_eval()
  expect_error(rd2html("\\Sexpr{x}"), "not found")
})

test_that("Sexprs run from package root", {
  skip_on_travis()
  # Because paths are different during R CMD check
  skip_if_not(file_exists("../../DESCRIPTION"))
  local_context_eval(src_path = "../..")

  # \packageTitle is built in macro that uses DESCRIPTION
  expect_equal(
    rd2html("\\packageTitle{pkgdown}"),
    "Make Static HTML Documentation for a Package"
  )
})

test_that("DOIs are linked", {
  # Because paths are different during R CMD check
  skip_if_not(file_exists("../../DESCRIPTION"))
  local_context_eval(src_path = "../..")

  expect_true(
    rd2html("\\doi{test}") %in%
      c("doi: <a href='http://doi.org/test'>test</a>",
        "doi: <a href='https://doi.org/test'>test</a>"
      )
  )
})

# links -------------------------------------------------------------------

test_that("can convert cross links to online documentation url", {
  expect_equal(
    rd2html("\\link[base]{library}"),
    a("library", href = "https://rdrr.io/r/base/library.html")
  )
})

test_that("can convert cross links to the same package (#242)", {
  withr::local_options(list(
    "downlit.package" = "test",
    "downlit.topic_index" = c(x = "y", z = "z"),
    "downlit.rdname" = "z"
  ))

  expect_equal(rd2html("\\link{x}"), "<a href='y.html'>x</a>")
  expect_equal(rd2html("\\link[test]{x}"), "<a href='y.html'>x</a>")
  # but no self links
  expect_equal(rd2html("\\link[test]{z}"), "z")
})

test_that("can parse local links with topic!=label", {
  withr::local_options(list(
    "downlit.topic_index" = c(x = "y")
  ))
  expect_equal(rd2html("\\link[=x]{z}"), "<a href='y.html'>z</a>")
})

test_that("functions in other packages generates link to rdrr.io", {
  withr::local_options(list(
    "downlit.package" = "test",
    "downlit.topic_index" = c(x = "y", z = "z")
  ))

  expect_equal(
    rd2html("\\link[stats:acf]{xyz}"),
    a("xyz", downlit::href_topic("acf", "stats"))
  )

  # Unless it's the current package
  expect_equal(rd2html("\\link[test:x]{xyz}"), "<a href='y.html'>xyz</a>")
})

test_that("link to non-existing functions return label", {
  expect_equal(rd2html("\\link[xyzxyz:xyzxyz]{abc}"), "abc")
  expect_equal(rd2html("\\link[base:xyzxyz]{abc}"), "abc")
})

test_that("code blocks autolinked to vignettes", {
  withr::local_options(list(
    "downlit.package" = "test",
    "downlit.article_index" = c("abc" = "abc.html")
  ))

  expect_equal(
    rd2html("\\code{vignette('abc')}"),
    "<code><a href='abc.html'>vignette('abc')</a></code>"
  )
})

test_that("link to non-existing functions return label", {
  withr::local_options(list(
    "downlit.package" = "test",
    "downlit.topic_index" = c("TEST-class" = "test")
  ))
  expect_equal(rd2html("\\linkS4class{TEST}"), "<a href='test.html'>TEST</a>")
})

# Paragraphs --------------------------------------------------------------

test_that("empty input gives empty output", {
  expect_equal(flatten_para(character()), character())
})

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

test_that("nested item with whitespace parsed correctly", {
  out <- rd2html("
    \\describe{
    \\item{Label}{

      This text is indented in a way pkgdown doesn't like.
  }}")
  expect_equal(out, c(
    "<dl>",
    "<dt>Label</dt><dd><p>This text is indented in a way pkgdown doesn't like.</p></dd>",
    "</dl>"
  ))
})

# Verbatim ----------------------------------------------------------------

# test_that("parseable preformatted blocks are highlighted", {
#   out <- flatten_para(rd_text("\\preformatted{1}"))
#   expect_equal(out, "<pre><span class='fl'>1</span></pre>\n")
#
#   out <- flatten_para(rd_text("\\preformatted{1 > 2}"))
#   expect_equal(out, "<pre><span class='fl'>1</span> <span class='op'>&gt;</span> <span class='fl'>2</span></pre>\n")
# })

test_that("unparseable blocks aren't double escaped", {
  out <- flatten_para(rd_text("\\preformatted{\\%>\\%}"))
  expect_equal(out, "<pre>%&gt;%</pre>\n")
})

test_that("newlines are preserved in preformatted blocks", {
  out <- flatten_para(rd_text("\\preformatted{^\n\nb\n\nc}"))
  expect_equal(out, "<pre>^\n\nb\n\nc</pre>\n")
})

test_that("spaces are preserved in preformatted blocks", {
  out <- flatten_para(rd_text("\\preformatted{^\n\n  b\n\n  c}"))
  expect_equal(out, "<pre>^\n\n  b\n\n  c</pre>\n")
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

  out <- rd2html("\\method{fun}{class}(x, y)")
  expect_equal(out[1], "# S3 method for class")
  expect_equal(out[2], "fun(x, y)")
})

test_that("eqn", {
  out <- rd2html(" \\eqn{\\alpha}{alpha}")
  expect_equal(out, "\\(\\alpha\\)")
  out <- rd2html(" \\eqn{x}")
  expect_equal(out, "\\(x\\)")
})

test_that("deqn", {
  out <- rd2html(" \\deqn{\\alpha}{alpha}")
  expect_equal(out, "$$\\alpha$$")
  out <- rd2html(" \\deqn{x}")
  expect_equal(out, "$$x$$")
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

# Rd tag errors ------------------------------------------------------------------

test_that("bad Rd tags throw errors", {
  verify_output(test_path("test-rd-html-error.txt"), {
    rd2html("\\url{}")
    rd2html("\\url{a\nb}")
    rd2html("\\email{}")
    rd2html("\\linkS4class{}")
    rd2html("\\enc{}")
  })
})
