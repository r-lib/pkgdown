test_that("can recognise intro variants", {
  expect_true(article_is_intro("package", "package"))
  expect_true(article_is_intro("articles/package", "package"))
  expect_true(article_is_intro("pack-age", "pack.age"))
  expect_true(article_is_intro("articles/pack-age", "pack.age"))
})

test_that("validates articles yaml", {
  data_articles_index_ <- function(x) {
    pkg <- local_pkgdown_site(meta = list(articles = x))
    data_articles_index(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_articles_index_(1)
    data_articles_index_(list(1))
    data_articles_index_(list(list()))
    data_articles_index_(list(list(title = 1, contents = 1)))
    data_articles_index_(list(list(title = "a\n\nb", contents = 1)))
    data_articles_index_(list(list(title = "a", contents = 1)))
  })
})

test_that("validates external-articles", {
  data_articles_ <- function(x) {
    pkg <- local_pkgdown_site(meta = list(`external-articles` = x))
    data_articles(pkg)
  }
  expect_snapshot(error = TRUE, {
    data_articles_(1)
    data_articles_(list(1))
    data_articles_(list(list(name = "x")))
    data_articles_(list(list(name = 1, title = "x", href = "x", description = "x")))
    data_articles_(list(list(name = "x", title = 1, href = "x", description = "x")))
    data_articles_(list(list(name = "x", title = "x", href = 1, description = "x")))
    data_articles_(list(list(name = "x", title = "x", href = "x", description = 1)))
  })
})

test_that("data_articles includes external articles", {
  pkg <- local_pkgdown_site()
  dir_create(path(pkg$src_path, "vignettes"))
  file_create(path(pkg$src_path, "vignettes", paste0(letters[1:2], ".Rmd")))
  pkg <- as_pkgdown(pkg$src_path, override = list(
    `external-articles` = list(
      list(name = "c", title = "c", href = "c", description = "*c*")
    )
  ))

  articles <- data_articles(pkg)
  expect_equal(articles$name, c("a", "b", "c"))
  expect_equal(articles$internal, rep(FALSE, 3))
  expect_equal(articles$description, list(NULL, NULL, "<p><em>c</em></p>"))
})

test_that("articles in vignettes/articles/ are unnested into articles/", {
  # weird path differences that I don't have the energy to dig into
  skip_on_cran()

  pkg <- local_pkgdown_site(test_path("assets/articles"))
  suppressMessages(init_site(pkg))
  suppressMessages(path <- build_article("articles/nested", pkg))

  expect_equal(
    path_real(path),
    path_real(path(pkg$dst_path, "articles", "nested.html"))
  )

  # Check automatic redirect from articles/articles/foo.html -> articles/foo.html
  pkg$meta$url <- "https://example.com"
  expect_snapshot(build_redirects(pkg))

  # Check that the redirect file exists in <dst>/articles/articles/
  redirect_path <- path(pkg$dst_path, "articles", "articles", "nested.html")
  expect_true(file_exists(redirect_path))

  # Check that we redirect to correct location
  html <- xml2::read_html(redirect_path)
  expect_match(
    xpath_attr(html, ".//meta[@http-equiv = 'refresh']", "content"),
    "https://example.com/articles/nested.html",
    fixed = TRUE
  )
})

test_that("warns about articles missing from index", {
  pkg <- local_pkgdown_site()
  write_lines(path = path(pkg$src_path, "_pkgdown.yml"), "
    articles:
    - title: External
      contents: [a, b]
  ")
  dir_create(path(pkg$src_path, "vignettes"))
  file_create(path(pkg$src_path, "vignettes", paste0(letters[1:3], ".Rmd")))
  pkg <- as_pkgdown(pkg$src_path)

  expect_snapshot(. <- data_articles_index(pkg), error = TRUE)
})

test_that("internal articles aren't included and don't trigger warning", {
  pkg <- local_pkgdown_site()
  write_lines(path = path(pkg$src_path, "_pkgdown.yml"), "
    articles:
    - title: External
      contents: [a, b]
    - title: internal
      contents: c
  ")
  dir_create(path(pkg$src_path, "vignettes"))
  file_create(path(pkg$src_path, "vignettes", paste0(letters[1:3], ".Rmd")))
  pkg <- as_pkgdown(pkg$src_path)

  expect_no_error(index <- data_articles_index(pkg))
  expect_length(index$sections, 1)
  expect_length(index$sections[[1]]$contents, 2)
})

test_that("default template includes all articles", {
  pkg <- local_pkgdown_site()
  dir_create(path(pkg$src_path, "vignettes"))
  file_create(path(pkg$src_path, "vignettes", "a.Rmd"))
  pkg <- as_pkgdown(pkg$src_path)

  expect_equal(default_articles_index(pkg)[[1]]$contents, "a")
})

test_that("check doesn't include getting started vignette", {
  pkg <- local_pkgdown_site(test_path("assets/articles-resources"))
  getting_started <- path(pkg$src_path, "vignettes", paste0(pkg$package, ".Rmd"))
  file_create(getting_started)
  withr::defer(file_delete(getting_started))

  pkg <- local_pkgdown_site(test_path("assets/articles-resources"), meta = "
    articles:
     - title: Title
       contents: resources
  ")

  expect_error(data_articles_index(pkg), NA)
})
