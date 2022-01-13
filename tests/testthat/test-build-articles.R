test_that("can recognise intro variants", {
  expect_true(article_is_intro("package", "package"))
  expect_true(article_is_intro("articles/package", "package"))
  expect_true(article_is_intro("pack-age", "pack.age"))
  expect_true(article_is_intro("articles/pack-age", "pack.age"))
})

test_that("links to man/figures are automatically relocated", {
  # weird path differences that I don't have the energy to dig into
  skip_on_cran()
  pkg <- local_pkgdown_site(test_path("assets/man-figures"))

  expect_output(copy_figures(pkg))
  expect_output(build_articles(pkg, lazy = FALSE))

  html <- xml2::read_html(path(pkg$dst_path, "articles", "kitten.html"))
  src <- xpath_attr(html, "//img", "src")

  expect_equal(src, c(
    "../reference/figures/kitten.jpg",
    "../reference/figures/kitten.jpg",
    "another-kitten.jpg"
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
  expect_equal(xpath_text(html, ".//h2//span"), c("1", "2"))

  # But title isn't affected
  expect_equal(xpath_text(html, ".//h1"), "html_document + as_is")

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
  expect_equal(xpath_text(html, ".//h2//span"), c("1", "2"))
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

test_that("finds external resources referenced by R code in the article html", {
  # weird path differences that I don't have the energy to dig into
  skip_on_cran()
  pkg <- local_pkgdown_site(test_path("assets", "articles-resources"))

  expect_output(path <- build_article("resources", pkg))

  # ensure that we the HTML references `<img src="external.png" />` directly
  expect_equal(
    xpath_attr(xml2::read_html(path), ".//img", "src"),
    "external.png"
  )

  # expect that `external.png` was copied to the rendered article directory
  expect_true(
    file_exists(path(path_dir(path), "external.png"))
  )
})

test_that("BS5 sidebar is removed if TOC is not used", {
  pkg <- local_pkgdown_site(test_path("assets/articles"), "
    template:
      bootstrap: 5
  ")

  expect_output(init_site(pkg))
  expect_output(toc_false_path <- build_article("toc-false", pkg))
  toc_false_html <- xml2::read_html(toc_false_path)

  # We don't have a main with .col-md-9 if TOC isn't present
  xpath_contents <- ".//main[contains(@class, 'col-md-9')]"
  expect_equal(xpath_length(toc_false_html, xpath_contents), 0)

  # The #pkgdown-sidebar is suppressed if the article has toc: false
  expect_equal(xpath_length(toc_false_html, ".//aside"), 0)
})

test_that("articles in vignettes/articles/ are unnested into articles/", {
  # weird path differences that I don't have the energy to dig into
  skip_if(identical(R.version$crt, "ucrt"))

  pkg <- local_pkgdown_site(test_path("assets/articles"))
  expect_output(path <- build_article("articles/nested", pkg))

  expect_equal(path, file.path(pkg$dst_path, "articles", "nested.html"))

  # Check automatic redirect from articles/articles/foo.html -> articles/foo.html
  pkg$meta$url <- "https://example.com"
  expect_output(build_redirects(pkg))

  # Check that the redirect file exists in <dst>/articles/articles/
  redirect_path <- path(pkg$dst_path, "articles", "articles", "nested.html")
  expect_true(file_exists(redirect_path))

  # Check that we redirect to correct location
  html <- xml2::read_html(redirect_path)
  expect_match(
    xpath_attr(html, ".//meta[@http-equiv = 'refresh']", "content"),
    "https://example.com/articles/nested.html",
    fixed = TRUE
  )
})

test_that("pkgdown deps are included only once in articles", {
  pkg <- local_pkgdown_site(test_path("assets/articles"), "
    template:
      bootstrap: 5
  ")

  expect_output(init_site(pkg))
  expect_output(path <- build_article("html-deps", pkg))

  html <- xml2::read_html(path)

  # jquery is only loaded once, even though it's also added by code in the article
  expect_equal(xpath_length(html, ".//script[(@src and contains(@src, '/jquery'))]"), 1)

  # same for bootstrap js and css
  str_subset_bootstrap <- function(x) {
    bs_rgx <- "bootstrap-[\\d.]+" # ex: bootstrap-5.1.0 not bootstrap-toc,
    grep(bs_rgx, x, value = TRUE, perl = TRUE)
  }
  bs_js_src <- str_subset_bootstrap(
    xpath_attr(html, ".//script[(@src and contains(@src, '/bootstrap'))]", "src")
  )
  expect_length(bs_js_src, 1)

  bs_css_href <- str_subset_bootstrap(
    xpath_attr(html, ".//link[(@href and contains(@href, '/bootstrap'))]", "href")
  )
  expect_length(bs_css_href, 1)
})
