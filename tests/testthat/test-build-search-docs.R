context("test-build-search-docs.R")

test_that("docsearch.json and sitemap.xml are valid", {
  skip_if_not_installed("jsonlite")

  search <- test_path("search-site")
  on.exit(clean_site(search))

  expect_output(init_site(search))
  json <- path(search, "docs", "docsearch.json")
  expect_true(jsonlite::validate(read_lines(json)))

  xml <- path(search, "docs", "sitemap.xml")
  schema <- xml2::read_xml(path(search, "sitemaps-schema-0.9.xsd"))
  expect_true(xml2::xml_validate(xml2::read_xml(xml), schema))
})

