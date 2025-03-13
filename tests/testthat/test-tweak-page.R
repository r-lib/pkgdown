test_that("links to vignettes & figures tweaked", {
  html <- xml2::read_html(
    '<body>
    <img src="vignettes/x.png" />
    <img src="../vignettes/x.png" />
    <img src="man/figures/x.png" />
    <img src="../man/figures/x.png" />
  </body>'
  )

  tweak_page(
    html,
    "article",
    list(bs_version = 3, desc = desc::desc(text = ""))
  )
  expect_equal(
    xpath_attr(html, ".//img", "src"),
    c(
      "articles/x.png",
      "../articles/x.png",
      "reference/figures/x.png",
      "../reference/figures/x.png"
    )
  )
})


test_that("reference index table is not altered", {
  html <- xml2::read_html(
    "<body>
    <div class='template-reference-index'>
      <table></table>
    </div>
  </body>"
  )
  pkg <- list(bs_version = 3, desc = desc::desc(text = ""))
  tweak_page(html, "reference-index", pkg)
  expect_equal(xpath_attr(html, ".//table", "class"), NA_character_)
})


test_that("articles get rescue highlighting for non-collapsed output", {
  html <- xml2::read_xml(
    "<body>
    <pre><code>1</code></pre>
    <pre class='downlit'><code>1</code></pre>
    <div class='sourceCode'><pre><code>1</code></pre></div>
  </body>"
  )
  pkg <- list(bs_version = 3, desc = desc::desc(text = ""))
  tweak_page(html, "article", pkg)

  pre <- xml2::xml_find_all(html, ".//pre")
  expect_equal(xml2::xml_find_num(pre, "count(.//span[@class])"), c(1, 0, 0))
})

test_that("toc removed if one or fewer headings", {
  html <- xml2::read_html(
    "<body>
    <main><h2></h2><h2></h2></main>
    <nav id='toc'></nav>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 1)

  html <- xml2::read_html(
    "<body>
    <main><h2></h2></main>
    <nav id='toc'></nav>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)

  html <- xml2::read_html(
    "<body>
    <main></main>
    <nav id='toc'></nav>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)
})

test_that("toc removed if one or fewer headings", {
  html <- xml2::read_html(
    "<body>
    <main><h2></h2><h2></h2></main>
    <aside><nav id='toc'></nav></aside>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 1)

  html <- xml2::read_html(
    "<body>
    <main><h2></h2></main>
    <aside><nav id='toc'></nav></aside>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)

  html <- xml2::read_html(
    "<body>
    <main></main>
    <aside><nav id='toc'></nav></aside>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//nav"), 0)
})


test_that("sidebar removed if empty", {
  html <- xml2::read_html(
    "<body>
    <main></main>
    <aside><nav id='toc'></nav></aside>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//div"), 0)
})


test_that("sidebar removed if empty", {
  html <- xml2::read_html(
    "<body>
    <main></main>
    <aside><nav id='toc'></nav></aside>
  </body>"
  )
  tweak_useless_toc(html)
  expect_equal(xpath_length(html, ".//aside"), 0)
})


# rmarkdown ---------------------------------------------------------------

test_that("h1 section headings adjusted to h2 (and so on)", {
  html <- xml2::read_html(
    "
    <div class='page-header'>
      <h1>Title</h1>
      <h4>Author</h4>
    </div>
    <div class='section level1'>
      <h1>1</h1>
      <div class='section level2'>
      <h2>1.1</h2>
      </div>
    </div>
    <div class='section level1'>
      <h1>2</h1>
    </div>
  "
  )
  tweak_rmarkdown_html(html)
  expect_equal(xpath_text(html, ".//h1"), "Title")
  expect_equal(xpath_text(html, ".//h2"), c("1", "2"))
  expect_equal(xpath_text(html, ".//h3"), "1.1")
  expect_equal(xpath_text(html, ".//h4"), "Author")
  expect_equal(
    xpath_attr(html, ".//div", "class"),
    c("page-header", "section level2", "section level3", "section level2")
  )
})

test_that("slashes not URL encoded during relative path conversion", {
  # Since the URL conversion process in tweak_markdown_html() makes calls to
  # fs::path_real() (which requires paths to exist), we create a
  # temporary pkgdown site directory and populate it with an image file, which
  # we can then reference in our test HTML file.

  # Create a site
  pkg <- local_pkgdown_site()

  # Add the referenced image in a subdirectory of vignettes.
  pkg <- pkg_add_kitten(pkg, "vignettes/img/")

  # Get the full path to the image.
  sim_path <- path_real(path(pkg$src_path, "vignettes/img/kitten.jpg"))

  # Simulate an output HTML file referencing the absolute path.
  html <- xml2::read_html(
    sprintf(
      '
    <body>
      <img src="%s" />
    </body>
    ',
      sim_path
    )
  )

  # Function should update the absolute path to a relative path.
  tweak_rmarkdown_html(html, path(pkg$src_path, "vignettes"))

  # Check that the relative path has a non-encoded slash.
  expect_equal(xpath_attr(html, ".//img", "src"), "img/kitten.jpg")
})
