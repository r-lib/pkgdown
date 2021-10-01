
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
