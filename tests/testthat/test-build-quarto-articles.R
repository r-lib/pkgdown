test_that("can build all quarto article", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/vig1.qmd")
  pkg <- pkg_add_file(pkg, "vignettes/vig2.qmd")

  suppressMessages(build_articles(pkg))

  expect_true(file_exists(path(pkg$dst_path, "articles/vig1.html")))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig2.html")))
})

test_that("can build a single quarto article", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/vig1.qmd")
  pkg <- pkg_add_file(pkg, "vignettes/vig2.qmd")

  suppressMessages(build_article("vig1", pkg))

  expect_true(file_exists(path(pkg$dst_path, "articles/vig1.html")))
  expect_false(file_exists(path(pkg$dst_path, "articles/vig2.html")))
})

test_that("doesn't do anything if no quarto articles", {
  pkg <- local_pkgdown_site()
  expect_no_error(suppressMessages(build_quarto_articles(pkg)))
})

test_that("can render a pdf qmd", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/vig1.qmd", pkg_vignette(
    format = list(pdf = list(toc = TRUE))
  ))

  expect_equal(pkg$vignettes$type, "qmd")
  expect_equal(pkg$vignettes$file_out, "articles/vig1.pdf")

  suppressMessages(build_article("vig1", pkg))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig1.pdf")))
})

test_that("auto-adjusts heading levels", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/vig1.qmd", pkg_vignette(
    "# Heading 1",
    "# Heading 2"
  ))

  suppressMessages(build_article("vig1", pkg))

  html <- xml2::read_html(path(pkg$dst_path, "articles/vig1.html"))
  expect_equal(xpath_text(html, "//h1"), "title")
  expect_equal(xpath_text(html, "//h2"), c("Heading 1", "Heading 2"))
})
