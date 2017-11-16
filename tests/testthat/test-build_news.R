context("build_news")

test_that("github links are added to news items", {
  path <- normalizePath(test_path("news-github-links"))
  pkg <- as_pkgdown(path)
  news_tbl <- data_news(pkg)

  user_link <- "<a href='http://github.com/hadley'>@hadley</a>"
  issue_link <- "<a href='https://github.com/hadley/pkgdown/issues/100'>#100</a>"

  expect_true(grepl(user_link, news_tbl$html))
  expect_true(grepl(issue_link, news_tbl$html))
})
