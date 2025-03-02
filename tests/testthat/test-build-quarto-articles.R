test_that("can build all quarto article", {
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/vig1.qmd")
  pkg <- pkg_add_file(pkg, "vignettes/vig2.qmd")

  suppressMessages(build_articles(pkg))

  expect_true(file_exists(path(pkg$dst_path, "articles/vig1.html")))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig2.html")))
})

test_that("can build a single quarto article", {
  skip_if_no_quarto()

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
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(
    pkg,
    "vignettes/vig1.qmd",
    pkg_vignette(
      format = list(pdf = list(toc = TRUE))
    )
  )

  expect_equal(pkg$vignettes$type, "qmd")
  expect_equal(pkg$vignettes$file_out, "articles/vig1.pdf")

  suppressMessages(build_article("vig1", pkg))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig1.pdf")))
})

test_that("auto-adjusts heading levels", {
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(
    pkg,
    "vignettes/vig1.qmd",
    pkg_vignette(
      "# Heading 1",
      "# Heading 2"
    )
  )

  suppressMessages(build_article("vig1", pkg))

  html <- xml2::read_html(path(pkg$dst_path, "articles/vig1.html"))
  expect_equal(xpath_text(html, "//h1"), "title")
  expect_equal(xpath_text(html, "//h2"), c("Heading 1\n", "Heading 2\n"))
})

test_that("we find out if quarto styles change", {
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/vig1.qmd")

  output_dir <- quarto_render(pkg, path(pkg$src_path, "vignettes", "vig1.qmd"))

  data <- data_quarto_article(pkg, path(output_dir, "vig1.html"), "vig1.qmd")
  expect_snapshot(cat(data$includes$style))
})

test_that("quarto articles are included in the index", {
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(
    pkg,
    "vignettes/vig1.qmd",
    pkg_vignette(
      "## Heading 1",
      "Some text"
    )
  )

  suppressMessages(build_article("vig1", pkg))
  index <- build_search_index(pkg)

  expect_equal(index[[1]]$path, "/articles/vig1.html")
  expect_equal(index[[1]]$what, "Heading 1")
  expect_equal(index[[1]]$text, "text") # some is a stop word
})

test_that("quarto headings get anchors", {
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(
    pkg,
    "vignettes/vig1.qmd",
    pkg_vignette(
      "## Heading 1",
      "### Heading 2"
    )
  )

  suppressMessages(build_article("vig1", pkg))
  html <- xml2::read_html(path(pkg$dst_path, "articles/vig1.html"))
  headings <- xpath_xml(html, "//h2|//h3")
  expect_equal(
    xpath_attr(headings, "./a", "href"),
    c("#heading-1", "#heading-2")
  )
})

test_that("can build quarto articles in articles folder", {
  skip_if_no_quarto()

  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/articles/vig1.qmd")
  pkg <- pkg_add_file(pkg, "vignettes/vig2.qmd")
  pkg <- pkg_add_file(pkg, "vignettes/articles/vig3.rmd")
  pkg <- pkg_add_file(pkg, "vignettes/vig4.rmd")

  suppressMessages(build_articles(pkg))

  expect_true(file_exists(path(pkg$dst_path, "articles/vig1.html")))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig2.html")))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig3.html")))
  expect_true(file_exists(path(pkg$dst_path, "articles/vig4.html")))
})
