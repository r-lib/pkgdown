test_that("can recognise intro variants", {
  expect_true(article_is_intro("package", "package"))
  expect_true(article_is_intro("articles/package", "package"))
  expect_true(article_is_intro("pack-age", "pack.age"))
  expect_true(article_is_intro("articles/pack-age", "pack.age"))
})

test_that("links to man/figures are automatically relocated", {
  pkg <- local_pkgdown_site(test_path("assets/man-figures"))

  expect_output(copy_figures(pkg))
  expect_output(build_articles(pkg, lazy = FALSE))

  html <- xml2::read_html(path(pkg$dst_path, "articles", "kitten.html"))
  src <- xpath_attr(html, "//img", "src")

  expect_equal(src, c(
    "../reference/figures/kitten.jpg",
    "../reference/figures/kitten.jpg",
    "another-kitten.jpg",
    "https://www.tidyverse.org/rstudio-logo.svg"
  ))

  # And files aren't copied
  expect_false(dir_exists(path(pkg$dst_path, "man")))
})

test_that("warns about missing images", {
  skip_if_not_installed("rlang", "0.99")
  pkg <- local_pkgdown_site(test_path("assets/bad-images"))
  expect_snapshot(build_articles(pkg))
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

test_that("can set width", {
  pkg <- local_pkgdown_site(test_path("assets/articles"), "
    code:
      width: 50
  ")

  expect_output(path <- build_article("width", pkg))
  html <- xml2::read_html(path)
  expect_equal(xpath_text(html, ".//pre")[[2]], "## [1] 50")
})

test_that("BS5 sidebar is removed if TOC is not used", {
  pkg <- local_pkgdown_site(test_path("assets/articles"), "
    template:
      bootstrap: 5
  ")

  expect_output(init_site(pkg))
  expect_output(toc_false_path <- build_article("toc-false", pkg))
  toc_false_html <- xml2::read_html(toc_false_path)

  # We don't have a div.contents with .col-md-9 if TOC isn't present
  xpath_contents <- ".//div[contains(@class, 'col-md-9') and contains(concat(@class, ' '), 'contents ')]"
  expect_equal(xpath_length(toc_false_html, xpath_contents), 0)

  # The #pkgdown-sidebar is suppressed if the article has toc: false
  expect_equal(xpath_length(toc_false_html, ".//*[@id = 'pkgdown-sidebar']"), 0)
})
