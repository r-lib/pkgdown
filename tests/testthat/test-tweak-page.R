test_that("first header is wrapped in page-header div", {
  html <- xml2::read_html('
    <h1>First</h1>
    <h1>Second</h1>
  ')

  tweak_homepage_html(html, bs_version = 3)
  expect_equal(xpath_attr(html, ".//div", "class"), "page-header")
})

test_that("links to vignettes & figures tweaked", {
  html <- xml2::read_html('<body>
    <img src="vignettes/x.png" />
    <img src="../vignettes/x.png" />
    <img src="man/figures/x.png" />
    <img src="../man/figures/x.png" />
  </body>')

  tweak_homepage_html(html, bs_version = 3)
  expect_equal(
    xpath_attr(html, ".//img", "src"),
    c("articles/x.png", "../articles/x.png", "reference/figures/x.png", "../reference/figures/x.png")
  )
})

