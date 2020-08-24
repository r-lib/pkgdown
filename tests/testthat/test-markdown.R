test_that("empty string works", {
  expect_equal(markdown_text(""), "")
})

test_that("header attributes are parsed", {
  index_xml <- markdown_text("# Header {.class #id}")

  expect_true(grepl("id=\"id\"", index_xml))
  expect_true(grepl("class=\".*? class\"", index_xml))
})
