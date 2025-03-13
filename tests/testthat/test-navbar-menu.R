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

test_that("bad inputs give clear error", {
  submenu <- menu_submenu(
    "Title",
    list(
      menu_submenu("Heading", list(menu_heading("Hi")))
    )
  )
  expect_snapshot(error = TRUE, {
    navbar_html(1)
    navbar_html(list(foo = 1))
    navbar_html(submenu)
  })
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
    navbar_html(menu_separator(), menu_depth = 0),
    '<li class="nav-item"><hr class="dropdown-divider"></li>'
  )

  expect_equal(
    navbar_html(menu_separator(), menu_depth = 1),
    '<li><hr class="dropdown-divider"></li>'
  )
})

test_that("icons warn if no aria-label", {
  reset_message_verbosity("icon-aria-label")

  expect_snapshot({
    . <- navbar_html(menu_icon("fa-question", "https://example.com", NULL))
  })
})

test_that("icons extract base iconset class automatically", {
  expect_match(
    navbar_html(menu_icon("fa-question", "https://example.com", "label")),
    'class="fa fa-question"',
    fixed = TRUE
  )

  expect_match(
    navbar_html(menu_icon("fab fab-github", "https://example.com", "label")),
    'class="fab fab-github"',
    fixed = TRUE
  )
})

test_that("can specify link target", {
  expect_match(
    navbar_html(menu_link("a", "b", target = "_blank")),
    'target="_blank"',
    fixed = TRUE
  )
})

test_that("can construct theme menu", {
  pkg <- local_pkgdown_site(
    meta = list(template = list(bootstrap = 5, `light-switch` = TRUE))
  )
  lightswitch <- navbar_components(pkg)$lightswitch
  expect_snapshot(cat(navbar_html(lightswitch)))
})

test_that("simple components don't change without warning", {
  expect_snapshot({
    cat(navbar_html(menu_heading("a")))
    cat(navbar_html(menu_link("a", "b")))
    cat(navbar_html(menu_separator()))
    cat(navbar_html(menu_search()))
  })
})

# Building blocks -----------------------------------------------------------

test_that("navbar_html_text() combines icons and text", {
  expect_equal(navbar_html_text(list(text = "a")), 'a')
  expect_equal(
    navbar_html_text(list(icon = "fas-github", `aria-label` = "github")),
    '<span class="fas fas-github"></span>'
  )
  expect_equal(
    navbar_html_text(list(
      text = "a",
      icon = "fas-github",
      `aria-label` = "github"
    )),
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
