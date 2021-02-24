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

test_that("markdown_text2() doesn't wrap single lines in p", {
  expect_equal(markdown_text2("**lala**"), "<strong>lala</strong>")
  expect_equal(
    markdown_text2('<img src="someimage" alt="" />'),
    '<img src=\"someimage\" alt=\"\">'
  )
})

test_that("markdown_text2() can handle multi-lines", {
  expect_equal(markdown_text2("**lala**\n\npof"), "<p><strong>lala</strong></p><p>pof</p>")
})

test_that("markdown_text2() doesn't add \n", {
  expect_equal(
    markdown_text2("<p><strong>lala</strong></p><p>pof</p>"),
    "<p><strong>lala</strong></p><p>pof</p>"
  )
})
