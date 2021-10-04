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
  js <- xpath_attr(html, ".//body//script", "src")
  # included for pandoc 2.7.3 - 2.9.2.1 improve accessibility
  js <- js[basename(js) != "empty-anchor.js"]
  expect_equal(js, character())
})

test_that("can build article that uses html_vignette", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))

  # theme is not set since html_vignette doesn't support it
  expect_output(expect_error(build_article("html-vignette", pkg), NA))
})

test_that("can override html_document() options", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  expect_output(path <- build_article("html-document", pkg))

  # Check that number_sections is respected
  html <- xml2::read_html(path)
  expect_equal(xpath_text(html, ".//h1//span"), c("1", "2"))

  # And no links or scripts are inlined
  expect_equal(xpath_length(html, ".//body//link"), 0)
  expect_equal(xpath_length(html, ".//body//script"), 0)
})

test_that("html widgets get needed css/js", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  expect_output(path <- build_article("widget", pkg))

  html <- xml2::read_html(path)
  css <- xpath_attr(html, ".//body//link", "href")
  js <- xpath_attr(html, ".//body//script", "src")

  expect_true("diffviewer.css" %in% basename(css))
  expect_true("diffviewer.js" %in% basename(js))
})

test_that("can override options with _output.yml", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  expect_output(path <- build_article("html-document", pkg))

  # Check that number_sections is respected
  html <- xml2::read_html(path)
  expect_equal(xpath_text(html, ".//h1//span"), c("1", "2"))
})
