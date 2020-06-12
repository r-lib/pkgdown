context("test-html-tweak.R")

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
  html <- xml2::read_html('<div class="contents">
                          <div id="x">
                          <h1>abc</h1>
                          </div>
                          </div>')

  tweak_anchors(html)

  expect_output_file(
    html %>% xml2::xml_find_first(".//h1") %>% as.character() %>% cat(),
    "assets/tweak-anchor.html",
    update = TRUE
  )
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

# homepage ----------------------------------------------------------------

test_that("page header modification succeeds", {
  html <- xml2::read_html('
    <h1 class="hasAnchor">
      <a href="#plot" class="anchor"> </a>
      <img src="someimage" alt=""> some text
    </h1>')

  tweak_homepage_html(html)

  expect_output_file(cat(as.character(html)), "assets/home-page-header.html")
})

test_that("links to vignettes & figures tweaked", {
  html <- xml2::read_html('
    <img src="vignettes/x.png" />
    <img src="man/figures/x.png" />
  ')

  tweak_homepage_html(html)

  expect_output_file(cat(as.character(html)), "assets/home-links.html")
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
