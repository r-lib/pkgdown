test_that("empty string works", {
  skip_if_not(rmarkdown::pandoc_available())
  expect_equal(
    markdown_text("", pkg = list(meta = list(url = "https://example.com"))),
    ""
  )
})

test_that("header attributes are parsed", {
  skip_if_not(rmarkdown::pandoc_available())
  index_xml <- markdown_text(
    "# Header {.class #id}",
    pkg = list(meta = list(url = "https://example.com"))
    )

  expect_match(index_xml, "id=\"id\"")
  expect_match(index_xml, "class=\".*? class\"")
})

test_that("markdown_inline() can handle inline", {
  expect_equal(
    markdown_inline("**lala**", pkg = list()),
    "<strong>lala</strong>"
  )
})

test_that("markdown_inline() errors if block for inline", {
  expect_snapshot_error(
    markdown_inline(
      "**lala**\n\npof",
      pkg = list(),
      where = c("authors", "sidebar", "after")
    ))
})

test_that("markdown_block() can handle block(s)", {
  expect_equal(
    markdown_block("**lala**", pkg = list()),
    "<p><strong>lala</strong></p>"
  )
  expect_equal(
    markdown_block("**lala**\n\npof", pkg = list()),
    "<p><strong>lala</strong></p><p>pof</p>"
  )
})


test_that("markdown_block() doesn't add \n", {
  expect_equal(
    markdown_block("<p><strong>lala</strong></p><p>pof</p>", pkg = list()),
    "<p><strong>lala</strong></p><p>pof</p>"
  )
})
