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
    data_articles_(list(list(
      name = 1,
      title = "x",
      href = "x",
      description = "x"
    )))
    data_articles_(list(list(
      name = "x",
      title = 1,
      href = "x",
      description = "x"
    )))
    data_articles_(list(list(
      name = "x",
      title = "x",
      href = 1,
      description = "x"
    )))
    data_articles_(list(list(
      name = "x",
      title = "x",
      href = "x",
      description = 1
    )))
  })
})

test_that("data_articles includes external articles", {
  pkg <- local_pkgdown_site(
    meta = list(
      `external-articles` = list(
        list(name = "c", title = "c", href = "c", description = "*c*")
      )
    )
  )
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/b.Rmd")

  articles <- data_articles(pkg)
  expect_equal(articles$name, c("a", "b", "c"))
  expect_equal(articles$internal, rep(FALSE, 3))
  expect_equal(articles$description, list(NULL, NULL, "<p><em>c</em></p>"))
})

test_that("articles in vignettes/articles/ are unnested into articles/", {
  # weird path differences that I don't have the energy to dig into
  skip_on_cran()

  pkg <- local_pkgdown_site(meta = list(url = "https://example.com"))
  pkg <- pkg_add_file(pkg, "vignettes/articles/nested.Rmd")

  nested <- pkg$vignettes[pkg$vignettes$name == "articles/nested", ]
  expect_equal(nested$file_out, "articles/nested.html")

  # Check automatic redirect from articles/articles/foo.html -> articles/foo.html
  expect_snapshot(build_redirects(pkg))
})

test_that("warns about articles missing from index", {
  pkg <- local_pkgdown_site(
    meta = list(
      articles = list(
        list(title = "External", contents = c("a", "b"))
      )
    )
  )
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/b.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/c.Rmd")

  expect_snapshot(. <- data_articles_index(pkg), error = TRUE)
})

test_that("internal articles aren't included and don't trigger warning", {
  pkg <- local_pkgdown_site(
    meta = list(
      articles = list(
        list(title = "External", contents = c("a", "b")),
        list(title = "internal", contents = "c")
      )
    )
  )
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/b.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/c.Rmd")

  expect_no_error(index <- data_articles_index(pkg))
  expect_length(index$sections, 1)
  expect_length(index$sections[[1]]$contents, 2)
})

test_that("default template includes all articles", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd")

  expect_equal(default_articles_index(pkg)[[1]]$contents, "a")
})

test_that("check doesn't include getting started vignette", {
  pkg <- local_pkgdown_site(
    meta = list(
      articles = list(list(title = "Vignettes", contents = "a"))
    )
  )
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd")
  pkg <- pkg_add_file(pkg, "vignettes/testpackage.Rmd")

  expect_no_error(data_articles_index(pkg))
})
