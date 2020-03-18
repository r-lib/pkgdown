test_that("adds github link when available", {
  verify_output(test_path("test-navbar/github.txt"), {
    pkg <- pkg_navbar()
    navbar_components(pkg)

    pkg <- pkg_navbar(github_url = "https://github.org/r-lib/pkgdown")
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

