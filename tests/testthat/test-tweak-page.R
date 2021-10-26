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

  tweak_page(html, "article", list(bs_version = 3, desc = desc::desc(text = "")))
  expect_equal(
    xpath_attr(html, ".//img", "src"),
    c("articles/x.png", "../articles/x.png", "reference/figures/x.png", "../reference/figures/x.png")
  )
})


test_that("reference index table is not altered", {
  html <- xml2::read_html("<body>
    <div class='template-reference-index'>
      <table></table>
    </div>
  </body>")
  pkg <- list(bs_version = 3, desc = desc::desc(text = ""))
  tweak_page(html, "reference-index", pkg)
  expect_equal(xpath_attr(html, ".//table", "class"), NA_character_)
})

test_that("toc removed if one or fewer headings", {
  html <- xml2::read_html("<body>
    <div id='container'><h2></h2><h2></h2></div>
    <nav id='toc'></nav>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 1)

  html <- xml2::read_html("<body>
    <div id='container'><h2></h2></div>
    <nav id='toc'></nav>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)

  html <- xml2::read_html("<body>
    <div id='container'></div>
    <nav id='toc'></nav>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)
})
