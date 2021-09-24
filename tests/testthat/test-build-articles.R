test_that("can recognise intro variants", {
  expect_true(article_is_intro("package", "package"))
  expect_true(article_is_intro("articles/package", "package"))
  expect_true(article_is_intro("pack-age", "pack.age"))
  expect_true(article_is_intro("articles/pack-age", "pack.age"))
})

test_that("links to man/figures are automatically relocated", {
  pkg <- test_path("assets/man-figures")
  dst <- withr::local_tempdir()

  expect_output(build_articles(pkg, override = list(destination = dst)))

  html <- xml2::read_html(path(dst, "articles", "kitten.html"))
  src <- html %>% xml2::xml_find_all("//img") %>% xml2::xml_attr("src")

  expect_equal(src, c(
    "../reference/figures/kitten.jpg",
    "../reference/figures/kitten.jpg",
    "another-kitten.jpg",
    "https://www.tidyverse.org/rstudio-logo.svg"
  ))

  # And files aren't copied
  expect_false(dir_exists(path(dst, "man")))
})
