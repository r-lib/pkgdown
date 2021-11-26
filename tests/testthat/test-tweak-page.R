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


test_that("articles get rescue highlighting for non-collapsed output", {
  html <- xml2::read_xml("<body>
    <pre><code>1</code></pre>
    <pre class='downlit'><code>1</code></pre>
    <div class='sourceCode'><pre><code>1</code></pre></div>
  </body>")
  pkg <- list(bs_version = 3, desc = desc::desc(text = ""))
  tweak_page(html, "article", pkg)

  pre <- xml2::xml_find_all(html, ".//pre")
  expect_equal(xml2::xml_find_num(pre, "count(.//span)"), c(1, 0, 0))
})

test_that("toc removed if one or fewer headings", {
  html <- xml2::read_html("<body>
    <main><h2></h2><h2></h2></main>
    <nav id='toc'></nav>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 1)

  html <- xml2::read_html("<body>
    <main><h2></h2></main>
    <nav id='toc'></nav>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)

  html <- xml2::read_html("<body>
    <main></main>
    <nav id='toc'></nav>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)
})

test_that("toc removed if one or fewer headings", {
  html <- xml2::read_html("<body>
    <main><h2></h2><h2></h2></main>
    <aside><nav id='toc'></nav></aside>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 1)

  html <- xml2::read_html("<body>
    <main><h2></h2></main>
    <aside><nav id='toc'></nav></aside>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)

  html <- xml2::read_html("<body>
    <main></main>
    <aside><nav id='toc'></nav></aside>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)
})


test_that("sidebar removed if empty", {
  html <- xml2::read_html("<body>
    <main></main>
    <aside><nav id='toc'></nav></aside>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//div"), 0)
})


test_that("sidebar removed if empty", {
  html <- xml2::read_html("<body>
    <main></main>
    <aside><nav id='toc'></nav></aside>
  </body>")
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//aside"), 0)
})

