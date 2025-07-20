test_that("adds github/gitlab/codeberg link when available", {
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
        articles = list(list(name = "all", contents = c("a", "b")))
      )
    )
  )

  "navbar without text"
  expect_snapshot(
    navbar_articles(
      pkg(
        articles = list(list(
          name = "all",
          contents = c("a", "b"),
          navbar = NULL
        ))
      )
    )
  )

  "navbar with label"
  expect_snapshot(
    navbar_articles(
      pkg(
        articles = list(list(
          name = "all",
          contents = c("a", "b"),
          navbar = "Label"
        ))
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

test_that("can control articles navbar through navbar meta", {
  pkg <- local_pkgdown_site(
    meta = list(
      navbar = list(
        components = list(
          articles = menu_submenu("Hi!", list(menu_heading("Hi")))
        )
      )
    )
  )
  pkg <- pkg_add_file(pkg, "vignettes/a.Rmd", pkg_vignette())
  pkg <- pkg_add_file(pkg, "vignettes/b.Rmd", pkg_vignette())

  navbar <- navbar_link_components(pkg)
  expect_equal(navbar$left$articles$text, "Hi!")
})

test_that("data_navbar() works by default", {
  pkg <- local_pkgdown_site(
    meta = list(
      repo = list(url = list(home = "https://github.com/r-lib/pkgdown/"))
    )
  )
  file_touch(path(pkg$src_path, "NEWS.md"))

  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar() can re-order default elements", {
  pkg <- local_pkgdown_site(
    meta = list(
      repo = list(url = list(home = "https://github.com/r-lib/pkgdown/")),
      navbar = list(
        structure = list(
          left = c("github", "search"),
          right = "news"
        )
      )
    )
  )
  file_create(path(pkg$src_path, "NEWS.md"))

  expect_snapshot(data_navbar(pkg)[c("left", "right")])
})

test_that("data_navbar() can remove elements", {
  pkg <- local_pkgdown_site(
    meta = list(
      navbar = list(
        structure = list(
          left = c("github", "search"),
          right = list()
        )
      )
    )
  )

  expect_equal(data_navbar(pkg)$right, "")
})

test_that("data_navbar() works with empty side", {
  pkg <- local_pkgdown_site(
    meta = list(navbar = list(structure = list(left = list(), right = list())))
  )

  expect_snapshot(data_navbar(pkg))
})

test_that("data_navbar_() errors with bad yaml specifications", {
  data_navbar_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    data_navbar(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_navbar_(navbar = list(structure = list(left = 1)))
    data_navbar_(navbar = list(right = "github"))
  })
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
    intro = menu_link("Get started", "articles/pkgdown.html"),
    reference = menu_link("Reference", "reference/index.html"),
    articles = menu_submenu(
      "Articles",
      list(
        menu_link("Auto-linking", "articles/linking.html"),
        menu_link("Search", "articles/search.html"),
        menu_link("Metadata", "articles/metadata.html"),
        menu_link(
          "Customize your pkgdown website",
          "articles/customization.html"
        ),
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
    articles = menu_submenu(
      "Articles",
      list(menu_heading("A"), menu_heading("B"))
    )
  )
  pkg <- list(bs_version = 5)

  right <- xml2::read_html(render_navbar_links(x, pkg = pkg, side = "right"))
  left <- xml2::read_html(render_navbar_links(x, pkg = pkg, side = "left"))

  expect_equal(
    xpath_attr(right, ".//ul", "class"),
    "dropdown-menu dropdown-menu-end"
  )
  expect_equal(xpath_attr(left, ".//ul", "class"), "dropdown-menu")
})
