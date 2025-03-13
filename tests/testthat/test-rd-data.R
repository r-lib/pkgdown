# Value blocks ------------------------------------------------------------

test_that("leading text parsed as paragraph", {
  # fmt: skip
  expected <- c(
    "<p>text</p>",
    "<dl>", "<dt>x</dt>", "<dd><p>y</p></dd>", "</dl>"
  )
  expect_equal(value2html("\ntext\n\\item{x}{y}"), expected)
  expect_equal(value2html("text\\item{x}{y}"), expected)
})

test_that("leading text is optional", {
  expect_equal(
    value2html("\\item{x}{y}"),
    c("<dl>", "<dt>x</dt>", "<dd><p>y</p></dd>", "</dl>")
  )
})

test_that("can process empty string", {
  expect_equal(value2html(""), character())
})

test_that("leading text is optional", {
  expect_equal(value2html("text"), "<p>text</p>")
})

test_that("items are optional", {
  value <- rd_text("\\value{text}", fragment = FALSE)
  expect_equal(as_data(value[[1]])$contents, "<p>text</p>")
})


test_that("whitespace between items doesn't affect grouping", {
  expect_equal(
    value2html("\\item{a}{b}\n\n\\item{c}{d}\n\n\\item{e}{f}"),
    # fmt: skip
    c(
      "<dl>",
        "<dt>a</dt>", "<dd><p>b</p></dd>", "", "",
        "<dt>c</dt>", "<dd><p>d</p></dd>", "", "",
        "<dt>e</dt>", "<dd><p>f</p></dd>",
      "</dl>"
    )
  )
})

test_that("leading whitespace doesn't break items", {
  expect_equal(
    value2html("\n\\item{a}{b}\n\n\\item{c}{d}\n\n\\item{e}{f}"),
    # fmt: skip
    c(
      "<dl>",
        "<dt>a</dt>", "<dd><p>b</p></dd>", "", "",
        "<dt>c</dt>", "<dd><p>d</p></dd>", "", "",
        "<dt>e</dt>", "<dd><p>f</p></dd>",
      "</dl>"
    )
  )
})

test_that("whitespace between text is not preserved", {
  expect_equal(
    value2html("a\n\nb\n\nc"),
    c("<p>a</p>", "<p>b</p>", "<p>c</p>")
  )
})

test_that("can have multiple interleaved blocks", {
  expect_equal(
    value2html("text1\\item{a}{b}\\item{c}{d}text2\\item{e}{f}"),
    # fmt: skip
    c(
      "<p>text1</p>",
      "<dl>",
        "<dt>a</dt>", "<dd><p>b</p></dd>",
        "<dt>c</dt>", "<dd><p>d</p></dd>",
      "</dl>",
      "<p>text2</p>",
      "<dl>", "<dt>e</dt>", "<dd><p>f</p></dd>", "</dl>"
    )
  )
})

test_that("other tags don't affect breaking (#2371)", {
  expect_equal(
    value2html("1\\code{xxx}\n2\n3"),
    c("<p>1<code>xxx</code>", "2", "3</p>")
  )
  # additionally teading whitespace
  expect_equal(
    value2html("1\\code{xxx}\n  2\n  3"),
    c("<p>1<code>xxx</code>", "2", "3</p>")
  )
})
