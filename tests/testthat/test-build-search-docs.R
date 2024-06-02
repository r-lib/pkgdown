test_that("docsearch.json and sitemap.xml are valid for BS 3 site", {
  pkg <- local_pkgdown_site(test_path("assets/search-site"))

  suppressMessages(build_site(pkg, new_process = FALSE))
  json <- path(pkg$dst_path, "docsearch.json")
  expect_true(jsonlite::validate(read_lines(json)))

  xml <- path(pkg$dst_path, "sitemap.xml")
  schema <- xml2::read_xml(path(pkg$src_path, "sitemaps-schema-0.9.xsd"))
  expect_true(xml2::xml_validate(xml2::read_xml(xml), schema))
})

test_that("build_search() builds the expected search.json with an URL", {
  pkg <- local_pkgdown_site(
    test_path("assets/news"),
    list(url = "https://example.com", development = list(mode = "devel"))
  )

  suppressMessages(init_site(pkg))
  suppressMessages(build_news(pkg))
  suppressMessages(build_home(pkg))
  suppressMessages(build_sitemap(pkg))

  json_path <- withr::local_tempfile()
  jsonlite::write_json(build_search_index(pkg), json_path, pretty = TRUE)
  expect_snapshot_file(json_path, "search.json")
})

test_that("build sitemap only messages when it updates", {
  pkg <- local_pkgdown_site(
    test_path("assets/news"),
    list(url = "https://example.com")
  )

  suppressMessages(init_site(pkg))
  suppressMessages(build_home(pkg))
  expect_snapshot({
    build_sitemap(pkg)
    build_sitemap(pkg)
  })
})

test_that("build_search() builds the expected search.json with no URL", {
  pkg <- local_pkgdown_site(
    test_path("assets/news"),
    list(development = list(mode = "devel"))
  )

  suppressMessages(init_site(pkg))
  suppressMessages(build_news(pkg))
  suppressMessages(build_home(pkg))
  suppressMessages(build_sitemap(pkg))

  json_path <- withr::local_tempfile()
  jsonlite::write_json(build_search_index(pkg), json_path, pretty = TRUE)
  expect_snapshot_file(json_path, "search-no-url.json")
})

test_that("sitemap excludes redirects", {
  pkg <- local_pkgdown_site(meta = list(
    url = "https://example.com",
    redirects = list(c("a.html", "b.html"))
  ))
  suppressMessages(build_redirects(pkg))
  expect_equal(get_site_paths(pkg), character())
})
