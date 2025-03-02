test_that("first header is wrapped in page-header div", {
  html <- xml2::read_html(
    '
    <h1>First</h1>
    <h1>Second</h1>
  '
  )

  tweak_homepage_html(html)
  expect_equal(xpath_attr(html, ".//div", "class"), "page-header")
})

test_that("removes dummy page-header", {
  html <- xml2::read_html(
    '
    <div class="page-header"><h1>Page header</h1></div>
    <h1>Header</h1>
  '
  )

  tweak_homepage_html(html)
  expect_equal(xpath_text(html, ".//h1"), "Header")
})


test_that("can remove first header", {
  html <- xml2::read_html(
    '
    <h1>First</h1>
    <h1>Second</h1>
  '
  )

  tweak_homepage_html(html, strip_header = TRUE)
  expect_equal(xpath_length(html, ".//div"), 0)
})

test_that("can remove logo", {
  # Without link
  html <- xml2::read_html(
    '
    <h1>First <img src="logo.png" /></h1>
  '
  )
  tweak_homepage_html(html, bs_version = 5, logo = "mylogo.png")
  expect_snapshot(xpath_xml(html, ".//div"))

  # With link
  html <- xml2::read_html(
    '
    <h1>First <a><img src="logo.png" /></a></h1>
  '
  )
  tweak_homepage_html(html, bs_version = 5, logo = "mylogo.png")
  expect_snapshot(xpath_xml(html, ".//div"))
})

# badges -------------------------------------------------------------------

test_that("can move badges to sidebar", {
  html <- xml2::read_html(
    '
    <h1>Title</h1>
    <div id="badges">
      <p><a href="x"><img src="y"></a></p>
    </div>
    <div class="dev-status"></div>
  '
  )
  tweak_sidebar_html(html)
  expect_snapshot(xpath_xml(html, ".//div"))
})


test_that("remove badges even if no dev-status div", {
  html <- xml2::read_html(
    '
    <h1>Title</h1>
    <div id="badges">
      <p><a href="x"><img src="y"></a></p>
    </div>
  '
  )
  tweak_sidebar_html(html)
  expect_snapshot(html)
})

test_that("remove dev-status & badges if badges suppress", {
  html <- xml2::read_html(
    '
    <h1>Title</h1>
    <div id="badges">
      <p><a href="x"><img src="y"></a></p>
    </div>
    <div class="dev-status"></div>
  '
  )
  tweak_sidebar_html(html, show_badges = FALSE)
  expect_equal(xpath_length(html, "//div"), 0)
})

test_that("doesn't find badges when they don't exist", {
  expect_equal(badges_extract_text("<h1></h1>"), character())
  expect_equal(badges_extract_text("<p></p>"), character())

  # first paragraph contains non-image components
  expect_equal(
    badges_extract_text(
      '<p><a href="url"><img src="img" alt="alt" /></a>Hi!</p>'
    ),
    character()
  )
})

test_that("finds single badge", {
  expect_equal(
    badges_extract_text('<main><p><a href="x"><img src="y"></a></p></main>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("finds badges in #badges div", {
  expect_equal(
    badges_extract_text(
      '<p></p><div id="badges"><a href="x"><img src="y"></a></div>'
    ),
    '<a href="x"><img src="y"></a>'
  )

  # even if there's extra text
  expect_equal(
    badges_extract_text(
      '<p></p><p><div id="badges"><a href="x"><img src="y"></a>Hi!</div></p>'
    ),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("can find badges in comments", {
  html <- '
    <h1>blop</h1>
    <p>I am the first paragraph!</p>
    <!-- badges: start -->
    <p><a href="x"><img src="y"></a></p>
    <!-- badges: end -->
  '
  expect_equal(badges_extract_text(html), '<a href="x"><img src="y"></a>')

  # produced by usethis
  html <- '
    <h1>blop</h1>
    <p>I am the first paragraph!</p>
    <!-- badges: start -->
    <p><a href="x"><img src="y"></a>
    <!-- badges: end -->
    </p>
  '
  expect_equal(badges_extract_text(html), '<a href="x"><img src="y"></a>')
})

test_that("ignores extraneous content", {
  html <- '
    <h1>blop</h1>
    <p>I am the first paragraph!</p>
    <!-- badges: start -->
    <p><a href="x"><img src="y"></a></p>
    <p>a</p>
    <p><a href="b.html">B</a></p>
    <!-- badges: end -->
  '
  expect_equal(badges_extract_text(html), '<a href="x"><img src="y"></a>')
})
