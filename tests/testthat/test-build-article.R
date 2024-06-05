test_that("can build article that uses html_vignette", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))

  # theme is not set since html_vignette doesn't support it
  expect_snapshot(expect_error(build_article("html-vignette", pkg), NA))
})

test_that("can override html_document() options", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  suppressMessages(path <- build_article("html-document", pkg))

  # Check that number_sections is respected
  html <- xml2::read_html(path)
  expect_equal(xpath_text(html, ".//h2//span"), c("1", "2"))

  # But title isn't affected
  expect_equal(xpath_text(html, ".//h1"), "html_document + as_is")

  # And no links or scripts are inlined
  expect_equal(xpath_length(html, ".//body//link"), 0)
  expect_equal(xpath_length(html, ".//body//script"), 0)
})

test_that("can override options with _output.yml", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  suppressMessages(path <- build_article("html-document", pkg))

  # Check that number_sections is respected
  html <- xml2::read_html(path)
  expect_equal(xpath_text(html, ".//h2//span"), c("1", "2"))
})

test_that("can set width", {
  pkg <- local_pkgdown_site(
    test_path("assets/articles"),
    list(code = list(width = 50))
  )
  suppressMessages(init_site(pkg))

  suppressMessages(path <- build_article("width", pkg))
  html <- xml2::read_html(path)
  expect_equal(xpath_text(html, ".//pre")[[2]], "## [1] 50")
})

test_that("bad width gives nice error", {
  pkg <- local_pkgdown_site(meta = list(code = list(width = "abc")))
  expect_snapshot(rmarkdown_setup_pkgdown(pkg), error = TRUE)
})

test_that("BS5 article laid out correctly with and without TOC", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  
  suppressMessages(toc_true_path <- build_article("standard", pkg))
  suppressMessages(toc_false_path <- build_article("toc-false", pkg))

  toc_true <- xml2::read_html(toc_true_path)
  toc_false <- xml2::read_html(toc_false_path)

  # Always has class col-md-9
  expect_equal(xpath_attr(toc_false, ".//main", "class"), "col-md-9")
  expect_equal(xpath_attr(toc_true, ".//main", "class"), "col-md-9")

  # The no sidebar without toc
  expect_equal(xpath_length(toc_true, ".//aside"), 1)
  expect_equal(xpath_length(toc_false, ".//aside"), 0)
})

test_that("titles are escaped when needed", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_article(pkg = pkg, name = "needs-escape"))

  html <- xml2::read_html(path(pkg$dst_path, "articles/needs-escape.html"))
  expect_equal(xpath_text(html, "//title", trim = TRUE), "a <-> b • testpackage")
  expect_equal(xpath_text(html, "//h1", trim = TRUE), "a <-> b")
})

test_that("output is reproducible by default, i.e. 'seed' is respected", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_article(pkg = pkg, name = "random"))

  html <- xml2::read_html(path(pkg$dst_path, "articles/random.html"))
  output <- xpath_text(html, "//main//pre")[[2]]
  expect_snapshot(cat(output))
})

test_that("reports on bad open graph meta-data", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  expect_snapshot(build_article(pkg = pkg, name = "bad-opengraph"), error = TRUE)
})

test_that("can control math mode", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/math.Rmd", "$1 + 1$")

  pkg$meta$template$`math-rendering` <- "mathml"
  suppressMessages(init_site(pkg))
  suppressMessages(build_article("math", pkg))
  html <- xml2::read_html(path(pkg$dst_path, "articles", "math.html"))
  expect_equal(xpath_length(html, ".//math"), 1)

  pkg$meta$template$`math-rendering` <- "mathjax"
  suppressMessages(init_site(pkg))
  suppressMessages(build_article("math", pkg))
  html <- xml2::read_html(path(pkg$dst_path, "articles", "math.html"))
  expect_equal(xpath_length(html, ".//span[contains(@class, 'math')]"), 1)
  
  pkg$meta$template$`math-rendering` <- "katex"
  suppressMessages(init_site(pkg))
  suppressMessages(build_article("math", pkg))
  html <- xml2::read_html(path(pkg$dst_path, "articles", "math.html"))
  expect_equal(xpath_length(html, ".//span[contains(@class, 'math')]"), 1)
  expect_contains(
    path_file(xpath_attr(html, ".//script", "src")),
    c("katex-auto.js", "katex.min.js")
  )
})

test_that("rmarkdown_template cleans up after itself", {
  pkg <- local_pkgdown_site()
  path <- NULL

  local({
    path <<- rmarkdown_template(pkg)
    expect_true(file_exists(path))
  })
  expect_false(file_exists(path))
})

test_that("build_article styles ANSI escapes", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/test.Rmd", c(
    "---",
    "title: title",
    "---",
    "```{r}",
    "cat(cli::col_red('X'), '\n')",
    "```"
  ))

  suppressMessages(path <- build_article("test", pkg))
  html <- xml2::read_html(path)
  expect_snapshot_output(xpath_xml(html, ".//code//span[@class='co']"))
})

# Errors -----------------------------------------------------------------------

test_that("build_article yields useful error if pandoc fails", {
  skip_on_cran() # fragile due to pandoc dependency
  skip_if_no_pandoc("2.18")

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/test.Rmd", "Hi")

  expect_snapshot(
    build_article("test", pkg, pandoc_args = "--fail-if-warnings"),
    error = TRUE
  )
})

test_that("build_article yields useful error if R fails", {
  skip_if_no_pandoc()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/test.Rmd", c(
    "---",
    "title: title",
    "---",
    "```{r}",
    "f <- function() g()",
    "g <- function() h()",
    "h <- function() rlang::abort('Error!')",
    "f()",
    "```"
  ))

  # check that error looks good
  expect_snapshot(build_article("test", pkg), error = TRUE)
  # check that traceback looks good - need extra work because rlang
  # avoids tracebacks in snapshots
  expect_snapshot(summary(expect_error(build_article("test", pkg))))
})

# Images -----------------------------------------------------------------------

test_that("build_article copies image files in subdirectories", {
  skip_if_no_pandoc()
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/test.Rmd", c(
    "```{r}",
    "#| fig-alt: alt-text",
    "knitr::include_graphics('test/kitten.jpg')",
    "```"
  ))
  pkg <- pkg_add_kitten(pkg, "vignettes/test")

  expect_snapshot(build_article("test", pkg))
  expect_equal(path_file(dir_ls(path(pkg$dst_path, "articles", "test"))), "kitten.jpg")
})

test_that("finds external resources referenced by R code", {
  # weird path differences that I don't have the energy to dig into
  skip_on_cran()
  pkg <- local_pkgdown_site(test_path("assets", "articles-resources"))
  suppressMessages(path <- build_article("resources", pkg))

  # ensure that we the HTML references `<img src="external.png" />` directly
  html <- xml2::read_html(path)
  expect_equal(xpath_attr(html, ".//img", "src"), "external.png")

  # expect that `external.png` was copied to the rendered article directory
  expect_true(file_exists(path(path_dir(path), "external.png")))
})

test_that("image links relative to output", {
  pkg <- local_pkgdown_site(test_path("assets/articles-images"))

  suppressMessages(init_site(pkg))
  suppressMessages(copy_figures(pkg))
  suppressMessages(build_article("kitten", pkg))

  html <- xml2::read_html(path(pkg$dst_path, "articles", "kitten.html"))
  src <- xpath_attr(html, "//main//img", "src")

  expect_equal(src, c(
    # knitr::include_graphics()
    "../reference/figures/kitten.jpg",
    "another-kitten.jpg",
    # rmarkdown image
    "../reference/figures/kitten.jpg",
    "another-kitten.jpg",
    # magick::image_read()
    "kitten_files/figure-html/magick-1.png",
    # figure
    "kitten_files/figure-html/plot-1.jpg"
  ))

  # And files aren't copied
  expect_false(dir_exists(path(pkg$dst_path, "man")))
})

test_that("warns about missing images", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/kitten.Rmd", "![foo](kitten.jpg)")

  expect_snapshot(build_article("kitten", pkg))
})

test_that("warns about missing alt-text", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/kitten.Rmd", "![](kitten.jpg)")
  expect_snapshot(build_article("kitten", pkg))
})

# External dependencies --------------------------------------------------------

test_that("pkgdown deps are included only once in articles", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  
  suppressMessages(path <- build_article("html-deps", pkg))
  html <- xml2::read_html(path)
  scripts <- path_file(xpath_attr(html, ".//script", "src"))
  styles <- path_file(xpath_attr(html, ".//link", "href"))

  # jquery only loaded once, even though it's also added by code in the article
  expect_length(grep("jquery-", scripts), 1)
  # similarly for bootstrap
  expect_length(grep("bootstrap.bundle", scripts), 1)
  expect_length(grep("bootstrap.min.css", styles), 1)

  # included for pandoc 2.7.3 - 2.9.2.1 improve accessibility
  # we always want to remove it
  expect_length(grep("empty-anchor", scripts), 0)
})

test_that("html widgets get needed css/js", {
  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  suppressMessages(path <- build_article("widget", pkg))

  html <- xml2::read_html(path)
  css <- xpath_attr(html, ".//body//link", "href")
  js <- xpath_attr(html, ".//body//script", "src")

  expect_true("diffviewer.css" %in% path_file(css))
  expect_true("diffviewer.js" %in% path_file(js))
})
