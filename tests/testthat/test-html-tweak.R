
# links -------------------------------------------------------------------

test_that("tweak_404() make URLs absolute", {
  html <- function() {
  xml2::read_html(
    '<div><div><div>
    <a href = "reference.html"></a>
    <link href = "reference.css"></link>
    <script src = "reference.js"></script>
    <img src = "reference.png" class="pkg-logo"></img>
    </div></div></div>'
  )
  }

  pkg <- list(
    meta = list(url = "https://example.com"),
    development = list(in_dev = FALSE)
  )
  prod_html <- html()
  tweak_404(prod_html, pkg)
  expect_snapshot(cat(as.character(xml2::xml_child(prod_html))))

  pkg <- list(
    meta = list(url = "https://example.com", development = "devel"),
    version = "3.0.0.999",
    development = list(in_dev = TRUE)
  )
  dev_html <- html()
  tweak_404(dev_html, pkg)
  expect_snapshot(cat(as.character(xml2::xml_child(dev_html))))
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
