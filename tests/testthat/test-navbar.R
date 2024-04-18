test_that("adds github/gitlab link when available", {
  pkg <- pkg_navbar()
  expect_snapshot_output(navbar_components(pkg))

  pkg <- pkg_navbar(github_url = "https://github.com/r-lib/pkgdown")
  expect_snapshot_output(navbar_components(pkg))

  pkg <- pkg_navbar(github_url = "https://gitlab.com/r-lib/pkgdown")
  expect_snapshot_output(navbar_components(pkg))
})

test_that("vignette with package name turns into getting started", {
  vig <- pkg_navbar_vignettes("test")
  pkg <- pkg_navbar(vignettes = vig)
  expect_snapshot_output(navbar_components(pkg))
})

test_that("can control articles navbar through articles meta", {
  pkg <- function(...) {
    vig <- pkg_navbar_vignettes(c("a", "b"))
    pkg_navbar(vignettes = vig, meta = list(...))
  }

  "Default: show all alphabetically"
  expect_snapshot(navbar_articles(pkg()))

  "No navbar sections: link to index"
  expect_snapshot(
    navbar_articles(
      pkg(
        articles = list(list(name = "all", contents = c("a", "b"))
        )
      )
    )
  )

  "navbar without text"
  expect_snapshot(
    navbar_articles(
      pkg(
        articles = list(list(name = "all", contents = c("a", "b"), navbar = NULL))
      )
    )
  )

  "navbar with label"
  expect_snapshot(
    navbar_articles(
      pkg(
        articles = list(list(name = "all", contents = c("a", "b"), navbar = "Label"))
      )
    )
  )

  "navbar with only some articles"
  expect_snapshot(
    navbar_articles(
      pkg(
        articles = list(
          list(name = "a", contents = "a", navbar = NULL),
          list(name = "b", contents = "b")
        )
     )
    )
  )

})

test_that("data_navbar() works by default", {
  pkg <- local_pkgdown_site(meta = list(
    news = list(one_page = FALSE, cran_dates = FALSE),
    repo = list(url = list(home = "https://github.com/r-lib/pkgdown/"))
  ))
  write_lines(file.path(pkg$src_path, "NEWS.md"), text = c(
    "# testpackage 2.0", "",
    "* bullet (#222 @someone)"
  ))

  pkg <- local_pkgdown_site(pkg)
  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar() can re-order default elements", {
  pkg <- local_pkgdown_site(meta = "
    repo:
      url:
        home: https://github.com/r-lib/pkgdown/

    navbar:
      structure:
        left: [github, reference]
        right: news
  ")
  file.create(file.path(pkg$src_path, "NEWS.md"))

  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar() can remove elements", {
  pkg <- local_pkgdown_site(meta = "
    repo:
      url:
        home: https://github.com/r-lib/pkgdown/

    navbar:
      structure:
        left: github
        right: ~
  ")

  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar() works with empty side", {
  pkg <- local_pkgdown_site(meta = "
    navbar:
      structure:
        left: []
        right: []
  ")

   expect_snapshot(data_navbar(pkg))
 })

test_that("data_navbar() errors with bad side specifications", {
  pkg <- local_pkgdown_site(meta = "
    navbar:
      structure:
        left: 1
  ")

   expect_snapshot(data_navbar(pkg), error = TRUE)
})

test_that("data_navbar() errors with bad left/right", {
  pkg <- local_pkgdown_site(meta = "
    navbar:
      right: [github]
  ")

   expect_snapshot(data_navbar(pkg), error = TRUE)
})


test_that("for bs4, default bg and type come from bootswatch", {
  style <- navbar_style(bs_version = 5)
  expect_equal(style, list(bg = "light", type = "light"))

  style <- navbar_style(theme = "cyborg", bs_version = 5)
  expect_equal(style, list(bg = "dark", type = "dark"))

  # but can override
  style <- navbar_style(list(bg = "primary"), bs_version = 5)
  expect_equal(style, list(bg = "primary", type = "dark"))

  style <- navbar_style(list(bg = "primary", type = "light"), bs_version = 5)
  expect_equal(style, list(bg = "primary", type = "light"))
})

test_that("render_navbar_links BS3 & BS4 default", {
  x <- list(
    intro = list(text = "Get started", href = "articles/pkgdown.html"),
    reference = list(text = "Reference", href = "reference/index.html"),
    articles = list(
      text = "Articles",
      menu = list(
        list(text = "Auto-linking",  href = "articles/linking.html"),
        list(text = "Search", href = "articles/search.html"),
        list(text = "Metadata", href = "articles/metadata.html"),
        list(text = "Customize your pkgdown website", href = "articles/customization.html"),
        list(text = "---------"),
        list(text = "More...", href = "articles/index.html")
      )
    ),
    news = list(text = "News", href = "news/index.html")
  )

  expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 3))))
  expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 4))))
})

test_that("render_navbar_links BS4 no divider before first element", {
  x <- list(
    articles = list(
      text = "Articles",
      menu = list(
        list(text = "---------"),
        list(text = "First section"),
        list(text = "Search", href = "articles/search.html"),
        list(text = "Metadata", href = "articles/metadata.html"),
        list(text = "Customize your pkgdown website", href = "articles/customization.html"),
        list(text = "---------"),
        list(text = "More...", href = "articles/index.html")
      )
    )
  )
  expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 4))))
})

test_that("can specific link target", {
  expect_snapshot({
    bs4_navbar_links_tags(
      list(menu = list(text = "text", href = "href", target = '_blank'))
    )
    bs4_navbar_links_tags(
      list(menu = list(text = "text", href = "href", target = '_blank')),
      depth = 1
    )
  })
})
