context("test-build-news.R")

test_that("build_news() uses content in NEWS.md", {
  pkg <- testthat::test_path("news")
  news_dir <- tempfile(pattern = "NEWS")

  build_news(normalizePath(pkg), path = news_dir)

  lines <- readLines(file.path(news_dir, "index.html"))
  test_strings <- c("testpackage", "1.0.0.9000", "1.0.0[^\\.]",
                    "sub-heading", "@githubuser", "bullet", "#111")
  expect_true(all(
    vapply(test_strings, function(x) any(grepl(x, lines)), logical(1))
  ))
  unlink(news_dir)
})
