test_that("empty string works", {
  skip_if_not(rmarkdown::pandoc_available())
  expect_equal(markdown_text(""), "")
})

test_that("header attributes are parsed", {
  skip_if_not(rmarkdown::pandoc_available())
  index_xml <- markdown_text("# Header {.class #id}")

  expect_true(grepl("id=\"id\"", index_xml))
  expect_true(grepl("class=\".*? class\"", index_xml))
})
