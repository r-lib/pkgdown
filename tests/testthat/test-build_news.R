context("build_news")

test_that("News sections are all valid and dev version is parsed", {
  pkg <- normalizePath(test_path("test-news"))
  news_tbl <- data_news(pkg)

  expect_false(any(is.na(news_tbl$version)))
  expect_identical(news_tbl$version, c("1.1.0.9000", "1.1.0", "1.0.0"))
  expect_identical(news_tbl$is_dev, c(TRUE, FALSE, FALSE))
})
