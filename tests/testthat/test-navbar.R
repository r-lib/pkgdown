test_that("adds github/gitlab link when available", {
  verify_output(test_path("test-navbar/github.txt"), {
    pkg <- pkg_navbar()
    navbar_components(pkg)

    pkg <- pkg_navbar(github_url = "https://github.com/r-lib/pkgdown")
    navbar_components(pkg)

    pkg <- pkg_navbar(github_url = "https://gitlab.com/r-lib/pkgdown")
    navbar_components(pkg)
  })
})

test_that("vignette with package name turns into getting started", {
  verify_output(test_path("test-navbar/getting-started.txt"), {
    vig <- pkg_navbar_vignettes("test")
    pkg <- pkg_navbar(vignettes = vig)
    navbar_components(pkg)
  })
})

test_that("can control articles navbar through articles meta", {
  verify_output(test_path("test-navbar/articles.txt"), {
    pkg <- function(...) {
      vig <- pkg_navbar_vignettes(c("a", "b"))
      pkg_navbar(vignettes = vig, meta = list(...))
    }

    "Default: show all alpabetically"
    navbar_articles(pkg())

    "No navbar sections: link to index"
    navbar_articles(pkg(articles = list(
      list(
        name = "all",
        contents = c("a", "b")
      )
    )))

    "navbar without text"
    navbar_articles(pkg(articles = list(
      list(
        name = "all",
        contents = c("a", "b"),
        navbar = NULL
      )
    )))

    "navbar with label"
    navbar_articles(pkg(articles = list(
      list(
        name = "all",
        contents = c("a", "b"),
        navbar = "Label"
      )
    )))

    "navbar with only some articles"
    navbar_articles(pkg(articles = list(
      list(
        name = "a",
        contents = "a",
        navbar = NULL
      ),
      list(
        name = "b",
        contents = "b"
      )
    )))

  })

})

test_that("data_navbar() works by default", {
  pkg <- as_pkgdown(test_path("assets/news-multi-page"))
  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar() can re-order default elements", {
  pkg <- as_pkgdown(test_path("assets/news-multi-page"))
  pkg$meta$navbar$structure$right <- c("news")
  pkg$meta$navbar$structure$left <- c("github", "reference")
  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar()can remove elements", {
  pkg <- as_pkgdown(test_path("assets/news-multi-page"))
  pkg$meta$navbar$structure$left <- c("github")
  pkg$meta$navbar$structure$right <- c("reference")
  expect_snapshot(data_navbar(pkg))
})
