test_that("empty string works", {
  skip_if_not(rmarkdown::pandoc_available())
  expect_equal(markdown_text(""), "")
})

test_that("header attributes are parsed", {
  skip_if_not(rmarkdown::pandoc_available())
  index_xml <- markdown_text("# Header {.class #id}")

  expect_match(index_xml, "id=\"id\"")
  expect_match(index_xml, "class=\".*? class\"")
})
