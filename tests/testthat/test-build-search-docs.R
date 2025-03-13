test_that("docsearch.json and sitemap.xml are valid for BS 3 site", {
  pkg <- local_pkgdown_site(
    meta = list(
      url = "https://example.com",
      template = list(
        bootstrap = 3,
        params = list(
          docsearch = list(
            api_key = "test-api-key",
            index_name = "test-index-name"
          )
        )
      )
    )
  )
  suppressMessages(build_docsearch_json(pkg))
  json <- path(pkg$dst_path, "docsearch.json")
  expect_true(jsonlite::validate(read_lines(json)))

  suppressMessages(build_sitemap(pkg))
  xml <- path(pkg$dst_path, "sitemap.xml")
  schema <- xml2::read_xml(test_path("assets/sitemaps-schema-0.9.xsd"))
  expect_true(xml2::xml_validate(xml2::read_xml(xml), schema))
})

test_that("build_search_index() has expected structure", {
  pkg <- local_pkgdown_site(
    desc = list(Version = "1.0.0"),
    meta = list(url = "https://example.com")
  )
  pkg <- pkg_add_file(
    pkg,
    "README.md",
    c(
      "# My Package",
      "What the pakage does"
    )
  )

  suppressMessages(init_site(pkg))
  suppressMessages(build_home_index(pkg))

  expect_snapshot(str(build_search_index(pkg)))
})

test_that("build sitemap only messages when it updates", {
  pkg <- local_pkgdown_site(meta = list(url = "https://example.com"))

  suppressMessages(init_site(pkg))
  suppressMessages(build_home(pkg))
  expect_snapshot({
    build_sitemap(pkg)
    build_sitemap(pkg)
  })
})

test_that("build_search() builds the expected search.json with no URL", {
  pkg <- local_pkgdown_site(desc = list(Version = "1.0.0"))
  pkg <- pkg_add_file(
    pkg,
    "README.md",
    c(
      "# My Package",
      "What the pakage does"
    )
  )

  suppressMessages(build_home(pkg))

  index <- build_search_index(pkg)
  paths <- purrr::map_chr(index, "path")
  expect_equal(paths, c("/authors.html", "/authors.html", "/index.html"))
})

test_that("sitemap excludes redirects", {
  pkg <- local_pkgdown_site(
    meta = list(
      url = "https://example.com",
      redirects = list(c("a.html", "b.html"))
    )
  )
  suppressMessages(build_redirects(pkg))
  expect_equal(get_site_paths(pkg), character())
})
