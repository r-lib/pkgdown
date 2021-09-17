test_that("docsearch.json and sitemap.xml are valid", {

  search <- test_path("assets/search-site")
  on.exit(clean_site(search))

  expect_output(build_site(search, new_process = FALSE))
  json <- path(search, "docs", "docsearch.json")
  expect_true(jsonlite::validate(read_lines(json)))

  xml <- path(search, "docs", "sitemap.xml")
  schema <- xml2::read_xml(path(search, "sitemaps-schema-0.9.xsd"))
  expect_true(xml2::xml_validate(xml2::read_xml(xml), schema))
})

test_that("build_search() builds the expected search.json", {
  path <- test_path("assets/news")
  pkg <- as_pkgdown(
    path,
    list(
      news = list(cran_dates = FALSE),
      url = "https://example.com",
      development = list(mode = "devel")
      )
    )
  pkg$bs_version <- 4
  tmp <- withr::local_tempdir()
  pkg$dst_path <- tmp
  build_news(pkg)
  build_home(pkg)
  build_sitemap(pkg)
  jsonlite::write_json(build_search_index(pkg), file.path(tmp, "search.json"), pretty = TRUE)
  expect_snapshot_file(file.path(tmp, "search.json"))
})
