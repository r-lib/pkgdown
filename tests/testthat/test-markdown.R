test_that("handles empty inputs", {
  expect_equal(markdown_text_inline(""), NULL)
  expect_equal(markdown_text_inline(NULL), NULL)

  expect_equal(markdown_text_block(NULL), NULL)
  expect_equal(markdown_text_block(""), NULL)
})

test_that("header attributes are parsed", {
  text <- markdown_text_block("# Header {.class #id}")
  expect_match(text, "id=\"id\"")
  expect_match(text, "class=\".*? class\"")
})

test_that("markdown_text_inline() works with inline markdown", {
  expect_equal(markdown_text_inline("**lala**"), "<strong>lala</strong>")
  expect_snapshot_error(markdown_text_inline("x\n\ny"))
})

test_that("markdown_text_block() works with inline and block markdown", {
  expect_equal(markdown_text_block("**x**"), "<p><strong>x</strong></p>")
  expect_equal(markdown_text_block("x\n\ny"), "<p>x</p><p>y</p>"
  )
})

test_that("markdown_body() captures title", {
  temp <- withr::local_tempfile()
  write_lines("# Title\n\nSome text", temp)

  html <- markdown_body(temp)
  expect_equal(attr(html, "title"), "Title")

  # And can optionally strip it
  html <- markdown_body(temp, strip_header = TRUE)
  expect_equal(attr(html, "title"), "Title")
  expect_false(grepl("Title", html))
})

test_that("markdown_text_*() handles UTF-8 correctly", {
  expect_equal(markdown_text_block("\u00f8"), "<p>\u00f8</p>")
  expect_equal(markdown_text_inline("\u00f8"), "\u00f8")
})
