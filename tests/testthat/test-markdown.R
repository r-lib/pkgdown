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
