# tables -------------------------------------------------------------

test_that("tables get class='table'", {
  html <- xml2::read_html("<body><table>\n</table></body>")
  tweak_tables(html)

  html %>%
    xml2::xml_find_all(".//table") %>%
    xml2::xml_attr("class") %>%
    expect_equal("table")
})

test_that("multiple tables with existing classes are prepended", {
  html <- xml2::read_html(
    "<body>
    <table class='a'></table>
    <table class='b'></table>
    <table></table>
    </body>"
  )
  expect_silent(tweak_tables(html))

  html %>%
    xml2::xml_find_all(".//table") %>%
    xml2::xml_attr("class") %>%
    expect_equal(c("table a", "table b", "table"))
})

test_that("multiple tables with existing classes are prepended and attributes", {
  html <- xml2::read_html(
    '<body>
    <table style="width:100%;" class="a"></table>
    <table class="b"></table>
    <table></table>
    </body>'
  )
  expect_silent(tweak_tables(html))
  html %>%
    xml2::xml_find_all(".//table") %>%
    xml2::xml_attr("class") %>%
    expect_equal(c("table a", "table b", "table"))
})

test_that("tables get class='table' prepended to existing classes", {
  html <- xml2::read_html("<body><table class = 'foo bar'>\n</table></body>")
  tweak_tables(html)

  html %>%
    xml2::xml_find_all(".//table") %>%
    xml2::xml_attr("class") %>%
    expect_equal("table foo bar")
})

test_that("tweaking tables does not touch other html", {
  html <- xml2::read_html("<body><em>foo</em></body>")
  html_orig <- html

  tweak_tables(html)

  expect_equal(as.character(html), as.character(html_orig))
})

# anchors -------------------------------------------------------------

test_that("anchors don't get additional newline", {
  html <- xml2::read_xml('<div class="contents">
                          <div id="x">
                          <h1>abc</h1>
                          </div>
                          </div>')

  tweak_anchors(html)
  expect_snapshot_output(show_xml(html))
})

# tags -------------------------------------------------------------

test_that("Stripping HTML tags", {
  expect_identical(
    strip_html_tags("<p>some text about <code>data</code>"),
    "some text about data"
  )
})


# links -------------------------------------------------------------------

test_that("only local md links are tweaked", {
  html <- xml2::read_html('
    <div class="contents">
      <div id="x">
        <a href="local.md"></a>
        <a href="http://remote.com/remote.md"></a>
      </div>
    </div>')

  tweak_md_links(html)

  href <- html %>%
    xml2::xml_find_all(".//a") %>%
    xml2::xml_attr("href")

  expect_equal(href[[1]], "local.html")
  expect_equal(href[[2]], "http://remote.com/remote.md")
})

test_that("tweak_all_links() add the external-link class", {
  html <- xml2::read_html('
    <div class="contents">
      <div id="x">
        <a href="#anchor"></a>
        <a href="http://remote.com/remote.md"></a>
        <a class = "thumbnail" href="http://remote.com/remote.md"></a>
        <a href="http://example.com/remote.md"></a>
      </div>
    </div>')

  tweak_all_links(
    html,
    pkg = list(meta = list(url = "http://example.com"))
    )

  links <- xml2::xml_find_all(html, ".//a")
  expect_false("class" %in% names(xml2::xml_attrs(links[[1]])))
  expect_equal(xml2::xml_attr(links[[2]], "class"), "external-link")
  expect_equal(xml2::xml_attr(links[[3]], "class"), "external-link thumbnail")
  expect_false("class" %in% names(xml2::xml_attrs(links[[4]])))
})

test_that("tweak_navbar_links() make URLs absolute", {
  html <- '<div><div><div><a href = "reference.html"></a></div></div></div>'

  pkg <- list(
    meta = list(url = "https://example.com"),
    development = list(in_dev = FALSE)
  )
  expect_equal(
    tweak_navbar_links(html, pkg),
    "<body><div><div><div><a href=\"https://example.com/reference.html\"></a></div></div></div></body>"
  )

  pkg <- list(
    meta = list(url = "https://example.com", development = "devel"),
    version = "3.0.0.999",
    development = list(in_dev = TRUE)
  )
  expect_equal(
    tweak_navbar_links(html, pkg),
    "<body><div><div><div><a href=\"https://example.com/dev/reference.html\"></a></div></div></div></body>"
  )
})

# homepage ----------------------------------------------------------------

test_that("page header modification succeeds", {
  html <- xml2::read_xml('
    <h1 class="hasAnchor">
      <a href="#plot" class="anchor"> </a>
      <img src="someimage" alt="" /> some text
    </h1>')

  tweak_homepage_html(html, bs_version = 3)
  expect_snapshot_output(show_xml(html))
})

test_that("links to vignettes & figures tweaked", {
  html <- xml2::read_xml('<body>
    <img src="vignettes/x.png" />
    <img src="man/figures/x.png" />
  </body>')

  tweak_homepage_html(html, bs_version = 3)
  expect_snapshot_output(show_xml(html))
})


# find badges -------------------------------------------------------------

test_that("no paragraph", {
  expect_equal(badges_extract_text("<h1></h1>"), character())
})

test_that("no badges in paragraph", {
  expect_equal(badges_extract_text("<p></p>"), character())
})

test_that("finds single badge", {
  expect_equal(
    badges_extract_text('<p><a href="x"><img src="y"></a></p>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("badges aren't extracted from first paragraph if it contains extra text", {
  expect_equal(
    badges_extract_text('<p><a href="url"><img src="img" alt="alt" /></a>Hi!</p>'),
    character()
  )
})

test_that("badges can be in special element", {
  expect_equal(
    badges_extract_text('<p></p><div id="badges"><a href="x"><img src="y"></a></div>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("badges in special element can be accompanied by text", {
  expect_equal(
    badges_extract_text('<p></p><p><div id="badges"><a href="x"><img src="y"></a>Hi!</div></p>'),
    '<a href="x"><img src="y"></a>'
  )
})

test_that("badges-paragraph a la usethis can be found", {
  string <- '
  <blockquote>
  <p>Connect to thisisatest, from R</p>
  </blockquote>
  <!-- badges: start -->
  <p>
  <a href=\"https://www.repostatus.org/#wip\" class=\"external-link\">
    <img src=\"https://www.repostatus.org/badges/latest/wip.svg\" alt=\"Project Status: WIP.\">
  </a>
  <a href=\"https://travis-ci.org/ropensci/rotemplate\" class=\"external-link\">
  <img src=\"https://travis-ci.org/ropensci/rotemplate.svg?branch=master\" alt=\"Build Status\">
  </a>
  <!-- badges: end -->
  </p>'

  badges_page <- xml2::read_html(string)
  expect_equal(length(badges_extract(badges_page)), 2)
})


test_that("complex badges structure can be found", {
  string <- '
  <blockquote>
  <p>Connect to thisisatest, from R</p>
  </blockquote>
  <!-- badges: start -->
  <p>
  <a href="https://travis-ci.org/thisisatest/thisisatest">
    <img src="https://travis-ci.org/thisisatest/thisisatest.svg?branch=master" alt="Linux Build Status">
  </a>
  </p>
  <!-- badges: end -->
  <div id="introduction" class="section level2">
  <h2 class="hasAnchor">
  <a href="#introduction" class="anchor"></a>Introduction</h2>
  <p>The thingie is a blabla.</p>
  <p>The <code>thisisatest</code> package also blabla.</p>'

  badges_page <- xml2::read_html(string)
  expect_equal(length(badges_extract(badges_page)), 1)
})

test_that("multiple badges-paragraphs can be found between comments", {
  string <- '
  <p></p>
  <!-- badges: start -->
  <ul>
  <li><a href="x"><img src="y"></a></li>
  <li><a href="z"><img src="f"></a></li>
  </ul>
  <!-- badges: end -->
  <p></p>'

  badges_page <- xml2::read_html(string)
  expect_equal(length(badges_extract(badges_page)), 2)
})

# navbar -------------------------------------------------------------

test_that("navbar_links_haystack()", {
  html <- function(){
  xml2::read_html('<div id="navbar" class="collapse navbar-collapse">
      <ul class="navbar-nav mr-auto ml-3">
<li class="nav-item">
  <a class="nav-link" href="articles/pkgdown.html">Get started</a>
</li>
<li class="nav-item">
  <a class="nav-link" href="reference/index.html">Reference</a>
</li>
<li class="nav-item dropdown">
  <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true">Articles</a>
  <div class="dropdown-menu" aria-labelledby="navbarDropdown">
    <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
    <a class="dropdown-item" href="articles/index.html">More</a>
      </div>
</li>
      </ul>
</div>')
  }
  expect_snapshot(
    navbar_links_haystack(html(), pkg = list(), path = "articles/bla.html")[, c("links", "similar")]
  )
  expect_snapshot(
    navbar_links_haystack(html(), pkg = list(), path = "articles/linking.html")[, c("links", "similar")]
  )
  expect_snapshot(
    navbar_links_haystack(html(), pkg = list(), path = "articles/pkgdown.html")[, c("links", "similar")]
  )
})

test_that("activate_navbar()", {
  html <- function(){
  xml2::read_html('<div id="navbar" class="collapse navbar-collapse">
      <ul class="navbar-nav mr-auto ml-3">
<li class="nav-item">
  <a class="nav-link" href="articles/pkgdown.html">Get started</a>
</li>
<li class="nav-item">
  <a class="nav-link" href="reference/index.html">Reference</a>
</li>
<li class="nav-item dropdown">
  <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true">Articles</a>
  <div class="dropdown-menu" aria-labelledby="navbarDropdown">
    <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
    <a class="dropdown-item" href="articles/index.html">More</a>
      </div>
</li>
      </ul>
</div>')
  }
  navbar <- html()
  activate_navbar(navbar, "reference/index.html", pkg = list())
  expect_snapshot_output(
    xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )


  navbar <- html()
  activate_navbar(navbar, "reference/thing.html", pkg = list())
 expect_snapshot_output(
    xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )
  navbar <- html()
  activate_navbar(navbar, "articles/pkgdown.html", pkg = list())
  expect_snapshot_output(
    xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )

  navbar <- html()
  activate_navbar(navbar, "articles/thing.html", pkg = list())
  expect_snapshot_output(
      xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )
})
