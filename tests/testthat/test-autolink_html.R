context("autolink_html")

test_that("autolink generats link", {
  autolink_html(test_path("autolink.html"), test_path("autolink-out.html"))

  out <- xml2::read_xml(test_path("autolink-out.html"))
  a <- out %>% xml2::xml_find_first(".//code/a")
  expect_true(xml2::xml_has_attr(a, "href"))
})
