context("build_news")

test_that("News sections are all valid and dev version is parsed", {
  pkg <- normalizePath(test_path("good-news"))
  news_tbl <- data_news(pkg)
  expect_false(any(is.na(news_tbl$version)))
  expect_identical(news_tbl$version, c("1.1.0.9000", "1.1.0", "1.0.0", "0.4.0"))
  expect_identical(news_tbl$is_dev, c(TRUE, FALSE, FALSE, FALSE))
})

test_that("Invalid NEWS.md is rejected", {
  pkg <- normalizePath(test_path("bad-news"))
  expect_error(data_news(pkg),
    "Invalid NEWS.md: versions must be in # or ## headings")
})
