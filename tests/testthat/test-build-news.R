context("test-build-news.R")

test_that("github links are added to news items", {
  skip_if_no_pandoc()

  path <- test_path("assets/news-github-links")
  pkg <- as_pkgdown(path, list(news = list(cran_dates = FALSE)))
  news_tbl <- data_news(pkg)

  user_link <- "<a href='https://github.com/hadley'>@hadley</a>"
  user_link2 <- "<a href='https://github.com/josue-rodriguez'>@josue-rodriguez</a>"
  issue_link <- "<a href='https://github.com/hadley/pkgdown/issues/100'>#100</a>"

  expect_true(grepl(user_link, news_tbl$html))
  expect_true(grepl(user_link2, news_tbl$html))
  expect_true(grepl(issue_link, news_tbl$html))
})

test_that("build_news() uses content in NEWS.md", {
  skip_if_no_pandoc()

  path <- test_path("assets/news")
  pkg <- as_pkgdown(path, list(news = list(cran_dates = FALSE)))

  expect_output(build_news(pkg))
  on.exit(clean_site(path))

  lines <- read_lines(path(path, "docs", "news", "index.html"))
  test_strings <- c(
    "testpackage", "1.0.0.9000", "1.0.0[^\\.]",
    "sub-heading", "@githubuser", "bullet", "#111"
  )
  expect_true(all(
    vapply(test_strings, function(x) any(grepl(x, lines)), logical(1))
  ))
})

test_that("pkg_timeline fails cleanly for unknown package", {
  skip_on_cran()
  expect_null(pkg_timeline("__XYZ___"))
})

test_that("pkg_timeline returns NULL if CRAN dates suppressed", {
  expect_null(pkg_timeline(list(meta = list(news = list(cran_dates = FALSE)))))
})

test_that("correct timeline for first ggplot2 releases", {
  skip_on_cran()

  timeline <- pkg_timeline("ggplot2")[1:3, ]
  expected <- data.frame(
    version = c("0.5", "0.5.1", "0.5.2"),
    date = as.Date(c("2007-06-01", "2007-06-09", "2007-06-18")),
    stringsAsFactors = FALSE
  )

  expect_equal(timeline, expected)
})

test_that("determines page style from meta", {
  expect_equal(news_style(meta = list()), "single")
  expect_equal(news_style(meta = list(news = list(one_page = FALSE))), "multi")
  expect_equal(news_style(meta = list(news = list(list(one_page = FALSE)))), "multi")
})

test_that("multi-page news are rendered", {
  skip_if_no_pandoc()

  path <- test_path("assets/news-multi-page")
  pkg <- as_pkgdown(path, list(news = list(cran_dates = FALSE)))
  on.exit(clean_site(pkg))
  expect_output(build_news(pkg))

  # test that index links are correct
  lines <- read_lines(path(path, "docs", "news", "index.html"))
  expect_true(any(grepl("<a href=\"news-2.0.html\">Version 2.0</a>", lines)))

  # test single page structure
  lines <- read_lines(path(path, "docs", "news", "news-1.0.html"))
  expect_true(any(grepl("<h1 data-toc-skip>Changelog <small>1.0</small></h1>", lines)))
})


# news_title and version_page -----------------------------------------------

test_that("can recognise common forms of title", {
  version <- news_version(c(
    "pkgdown 1.3.0",
    "pkgdown v1.3.0",
    "pkgdown (development version)"
  ))
  expect_equal(version, c("1.3.0", "1.3.0", "development version"))
})

test_that("correctly collapses version to page for common cases", {
  versions <- c("1.0.0", "1.0.0.0", "1.0.0.9000", "development version")
  pages <- purrr::map_chr(versions, version_page)
  expect_equal(pages, c("1.0", "1.0", "dev", "dev"))
})
