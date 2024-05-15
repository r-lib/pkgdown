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
  write_lines(path(pkg$src_path, "NEWS.md"), text = c(
    "# testpackage 2.0", "",
    "* bullet (#222 @someone)"
  ))

  pkg <- local_pkgdown_site(pkg)
  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar() can re-order default elements", {
  pkg <- local_pkgdown_site(meta = "
    template: 
      bootstrap: 5
    repo:
      url:
        home: https://github.com/r-lib/pkgdown/

    navbar:
      structure:
        left: [github, search]
        right: [news]
  ")
  file.create(path(pkg$src_path, "NEWS.md"))

  expect_snapshot(data_navbar(pkg)[c("left", "right")])
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

  expect_equal(data_navbar(pkg)$right, "")
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
    intro =  menu_link("Get started", "articles/pkgdown.html"),
    reference = menu_link("Reference", "reference/index.html"),
    articles = menu_submenu(
      "Articles",
      list(
        menu_link("Auto-linking", "articles/linking.html"),
        menu_link("Search", "articles/search.html"),
        menu_link("Metadata", "articles/metadata.html"),
        menu_link("Customize your pkgdown website", "articles/customization.html"),
        menu_separator(),
        menu_link("More...", "articles/index.html")
      )
    ),
    news = menu_link("News", "news/index.html")
  )

  expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 3))))
  expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 4))))
})

test_that("dropdowns on right are right-aligned", {
  x <- list(
    articles = list(
      text = "Articles",
      children = list(
        list(text = "A"),
        list(text = "B"),
        list(text = "C")
      )
    )
  )
  pkg <- list(bs_version = 5)
  
  right <- xml2::read_html(render_navbar_links(x, pkg = pkg, side = "right"))
  left <-  xml2::read_html(render_navbar_links(x, pkg = pkg, side = "left"))

  expect_equal(xpath_attr(right, ".//ul", "class"), "dropdown-menu dropdown-menu-end")
  expect_equal(xpath_attr(left, ".//ul", "class"), "dropdown-menu")
})
