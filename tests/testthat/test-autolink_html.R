context("test-autolink_html.R")

test_that("autolink generats link", {
  autolink_html(test_path("assets/autolink.html"), test_path("assets/autolink-out.html"))

  out <- xml2::read_xml(test_path("assets/autolink-out.html"))
  a <- out %>% xml2::xml_find_first(".//code/a")
  expect_true(xml2::xml_has_attr(a, "href"))
})
