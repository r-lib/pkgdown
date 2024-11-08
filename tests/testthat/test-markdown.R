test_that("handles empty inputs (returns NULL)", {
  pkg <- local_pkgdown_site()
  expect_null(markdown_text_inline(pkg, ""))
  expect_null(markdown_text_inline(pkg, NULL))
  expect_null(markdown_text_block(pkg, NULL))
  expect_null(markdown_text_block(pkg, ""))

  path <- withr::local_tempfile()
  file_create(path)
  expect_null(markdown_body(pkg, path))
})

test_that("header attributes are parsed", {
  pkg <- local_pkgdown_site()
  text <- markdown_text_block(pkg, "# Header {.class #id}")
  expect_match(text, "id=\"id\"")
  expect_match(text, "class=\".*? class\"")
})

test_that("markdown_text_inline() works with inline markdown", {
  pkg <- local_pkgdown_site()
  expect_equal(markdown_text_inline(pkg, "**lala**"), "<strong>lala</strong>")

  expect_snapshot(error = TRUE, {
    markdown_text_inline(pkg, "x\n\ny", error_path = "title")
  })
})

test_that("markdown_text_block() works with inline and block markdown", {
  skip_if_no_pandoc("2.17.1")

  pkg <- local_pkgdown_site()
  expect_equal(markdown_text_block(pkg, "**x**"), "<p><strong>x</strong></p>")
  expect_equal(markdown_text_block(pkg, "x\n\ny"), "<p>x</p><p>y</p>")
})

test_that("markdown_body() captures title", {
  pkg <- local_pkgdown_site()
  temp <- withr::local_tempfile(lines = "# Title\n\nSome text")

  html <- markdown_body(pkg, temp)
  expect_equal(attr(html, "title"), "Title")

  # And can optionally strip it
  html <- markdown_body(pkg, temp, strip_header = TRUE)
  expect_equal(attr(html, "title"), "Title")
  expect_no_match(html, "Title")
})

test_that("markdown_text_*() handles UTF-8 correctly", {
  pkg <- local_pkgdown_site()
  expect_equal(markdown_text_block(pkg, "\u00f8"), "<p>\u00f8</p>")
  expect_equal(markdown_text_inline(pkg, "\u00f8"), "\u00f8")
})

test_that("validates math yaml", {
  config_math_rendering_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(template = list(...)))
    config_math_rendering(pkg)
  }
  expect_snapshot(error = TRUE, {
    config_math_rendering_(`math-rendering` = 1)
    config_math_rendering_(`math-rendering` = "math")
  })
})

test_that("preserves ANSI characters", {
    withr::local_options(cli.num_colors = 256)
    pkg <- local_pkgdown_site()
    expect_snapshot(
      markdown_text(pkg, sprintf("prefer %s", cli::col_blue("a")))
    )
})
