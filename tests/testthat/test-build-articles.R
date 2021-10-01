test_that("can recognise intro variants", {
  expect_true(article_is_intro("package", "package"))
  expect_true(article_is_intro("articles/package", "package"))
  expect_true(article_is_intro("pack-age", "pack.age"))
  expect_true(article_is_intro("articles/pack-age", "pack.age"))
})

test_that("articles don't include header-attrs.js script", {
  pkg <- as_pkgdown(test_path("assets/articles"))
  withr::defer(clean_site(pkg))

  expect_output(path <- build_article("standard", pkg))

  html <- xml2::read_html(path)
  js <- html %>% xml2::xml_find_all(".//body//script") %>% xml2::xml_attr("src")
  expect_equal(js, character())
})

test_that("can build article that uses html_vignette", {
  pkg <- as_pkgdown(test_path("assets/articles"))
  withr::defer(clean_site(pkg))

  # theme is not set since html_vignette doesn't support it
  expect_output(expect_error(build_article("html-vignette", pkg), NA))
})

test_that("can override html_document() options", {
  pkg <- as_pkgdown(test_path("assets/articles"))
  withr::defer(clean_site(pkg))

  expect_output(path <- build_article("html-document", pkg))

  # Check that number_sections is respected
  html <- xml2::read_html(path)
  expect_equal(
    html %>% xml2::xml_find_all(".//h1//span") %>% xml2::xml_text(),
    c("1", "2")
  )

  css <- html %>% xml2::xml_find_all(".//body//link") %>% xml2::xml_attr("href")
  js <- html %>% xml2::xml_find_all(".//body//script") %>% xml2::xml_attr("src")
  expect_equal(length(css), 0)
  expect_equal(length(js), 0)
})

test_that("html widgets get needed css/js", {
  pkg <- as_pkgdown(test_path("assets/articles"))
  withr::defer(clean_site(pkg))

  expect_output(path <- build_article("widget", pkg))

  html <- xml2::read_html(path)
  css <- html %>% xml2::xml_find_all(".//body//link") %>% xml2::xml_attr("href")
  js <- html %>% xml2::xml_find_all(".//body//script") %>% xml2::xml_attr("src")

  expect_true("diffviewer.css" %in% basename(css))
  expect_true("diffviewer.js" %in% basename(js))
})

test_that("can override options with _output.yml", {
  pkg <- as_pkgdown(test_path("assets/article-output"))
  withr::defer(clean_site(pkg))

  expect_output(path <- build_article("html-document", pkg))

  # Check that number_sections is respected
  html <- xml2::read_html(path)
  expect_equal(
    html %>% xml2::xml_find_all(".//h1//span") %>% xml2::xml_text(),
    c("1", "2")
  )
})

