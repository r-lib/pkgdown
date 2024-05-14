test_that("can construct menu with children", {
  menu <- menu_submenu(
    "Title",
    list(
      menu_heading("Heading"),
      menu_separator(),
      menu_link("Link", "https://example.com")
    )
  )
  expect_snapshot(cat(navbar_html(menu)))
})

test_that("can construct nested menu", {
  menu <- menu_submenu(
    "Title",
    list(
      menu_heading("Heading"),
      menu_submenu("Submenu", list(
        menu_link("Link", "https://example.com")
      ))
    )
  )
  expect_snapshot(cat(navbar_html(menu)))
})


test_that("can construct bullets", {
  expect_snapshot({
    cat(navbar_html(menu_icon("fa-question", "https://example.com", "label")))
    cat(navbar_html(menu_heading("Hi")))
    cat(navbar_html(menu_link("Hi", "https://example.com")))
  })
})

test_that("bullet class varies based on depth", {
  expect_equal(
    navbar_html(menu_separator(), depth = 0),
    '<li class="nav-item"><hr class="dropdown-divider"></li>'
  )

  expect_equal(
    navbar_html(menu_separator(), depth = 1),
    '<li class="dropdown-item"><hr class="dropdown-divider"></li>'
  )
})

test_that("simple components don't change without warning", {
  expect_snapshot({
    cat(navbar_html_heading(menu_heading("a")))
    cat(navbar_html_link(menu_link("a", "b")))
    cat(navbar_html_separator())
    cat(navbar_html_search())
  })
})

# Building blocks -----------------------------------------------------------

test_that("navbar_html_text() combines icons and text", {
  expect_equal(navbar_html_text(list(text = "a")), 'a')
  expect_equal(
    navbar_html_text(list(icon = "fas-github")),
    '<span class="fas fas-github"></span>'
  )
  expect_equal(
    navbar_html_text(list(text = "a", icon = "fas-github")),
    '<span class="fas fas-github"></span> a'
  )
})

test_that("navbar_html_text() escapes text", {
  expect_equal(navbar_html_text(list(text = "<>")), '&lt;&gt;')
})

test_that("named arguments become attributes", {
  expect_equal(html_tag("a"), '<a></a>')
  expect_equal(html_tag("a", x = NULL), '<a></a>')
  expect_equal(html_tag("a", x = NA), '<a x></a>')
  expect_equal(html_tag("a", x = 1), '<a x="1"></a>')
})

test_that("unnamed arguments become children", {
  expect_equal(html_tag("a", "b"), '<a>b</a>')
  expect_equal(html_tag("a", "b", NULL), '<a>b</a>')
})

test_that("class components are pasted together", {
  expect_equal(html_tag("a", class = NULL), '<a></a>')
  expect_equal(html_tag("a", class = "a"), '<a class="a"></a>')
  expect_equal(html_tag("a", class = c("a", "b")), '<a class="a b"></a>')
})

# -------

# test_that("render_navbar_links BS3 & BS4 default", {
#   x <- list(
#     intro = list(text = "Get started", href = "articles/pkgdown.html"),
#     reference = list(text = "Reference", href = "reference/index.html"),
#     articles = list(
#       text = "Articles",
#       menu = list(
#         list(text = "Auto-linking",  href = "articles/linking.html"),
#         list(text = "Search", href = "articles/search.html"),
#         list(text = "Metadata", href = "articles/metadata.html"),
#         list(text = "Customize your pkgdown website", href = "articles/customization.html"),
#         list(text = "---------"),
#         list(text = "More...", href = "articles/index.html")
#       )
#     ),
#     news = list(text = "News", href = "news/index.html")
#   )

#   expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 3))))
#   expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 4))))
# })

# test_that("render_navbar_links BS4 no divider before first element", {
#   x <- list(
#     articles = list(
#       text = "Articles",
#       menu = list(
#         list(text = "---------"),
#         list(text = "First section"),
#         list(text = "Search", href = "articles/search.html"),
#         list(text = "Metadata", href = "articles/metadata.html"),
#         list(text = "Customize your pkgdown website", href = "articles/customization.html"),
#         list(text = "---------"),
#         list(text = "More...", href = "articles/index.html")
#       )
#     )
#   )
#   expect_snapshot(cat(render_navbar_links(x, pkg = list(bs_version = 4))))
# })


# test_that("can specific link target", {
#   expect_snapshot({
#     bs4_navbar_links_tags(
#       list(menu = list(text = "text", href = "href", target = '_blank'))
#     )
#     bs4_navbar_links_tags(
#       list(menu = list(text = "text", href = "href", target = '_blank')),
#       depth = 1
#     )
#   })
# })

# test_that("can render search helper", {
#   expect_snapshot({
#     bs4_navbar_links_tags(list(menu = list(search = TRUE)))
#   })
# })

# test_that("icons extract icon set", {
#   expect_equal(
#     as.character(bs4_navbar_link_text(menu_icon("github", ""))),
#     '<span class="fa fas fa-github fa-lg"></span>'
#   )
#   expect_equal(
#     as.character(bs4_navbar_link_text(menu_icon("github", "", style = "fab"))),
#     '<span class="fa fab fa-github fa-lg"></span>'
#   )
# })
