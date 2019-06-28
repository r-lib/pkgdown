context("test-autolink_html.R")

autolink_html(test_path("assets/autolink.html"), test_path("assets/autolink-out.html"))
on.exit(fs::file_delete(test_path("assets/autolink-out.html")))
out <- xml2::read_xml(test_path("assets/autolink-out.html"))

test_that("code is linked", {
  a <- out %>% xml2::xml_find_first(".//code/a")
  expect_true(xml2::xml_has_attr(a, "href"))
})

test_that("headers are not linked", {
  h1 <- out %>% xml2::xml_find_first(".//h1/code")
  expect_false(xml2::xml_has_attr(h1, "a"))
  h2 <- out %>% xml2::xml_find_first(".//h2/code")
  expect_false(xml2::xml_has_attr(h2, "a"))
})
