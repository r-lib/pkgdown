context("extract tags")
rd <- tempfile()

test_that("multiline title tags are handled reasonably", {

  writeLines("\\title{
This is a nice title starting with a newline
}", rd)

  rd_file(rd) %>%
    extract_tag("tag_title") %>%
    expect_equal("This is a nice title starting with a newline")

  writeLines("\\title{This is a title
containing a newline}", rd)
  
  rd_file(rd) %>%
    extract_tag("tag_title") %>%
    expect_equal("This is a title\ncontaining a newline")
})

test_that("multiple tags are handled correctly",  {

  writeLines("
\\alias{test_alias_1}
\\alias{test_alias_2}
\\alias{test_alias_3}", rd)
  rd_file(rd) %>%
    extract_tag("tag_alias") %>%
    expect_equal(paste("test_alias", 1:3, sep = "_"))
})
