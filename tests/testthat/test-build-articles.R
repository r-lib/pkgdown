test_that("can recognise intro variants", {
  expect_true(article_is_intro("package", "package"))
  expect_true(article_is_intro("articles/package", "package"))
  expect_true(article_is_intro("pack-age", "pack.age"))
  expect_true(article_is_intro("articles/pack-age", "pack.age"))
})

test_that("can build article that uses html_vignette", {
  pkg <- as_pkgdown(test_path("assets/article-html-vignette"))
  withr::defer(clean_site(pkg))

  expect_output(expect_error(build_article("html-vignette", pkg), NA))
})

