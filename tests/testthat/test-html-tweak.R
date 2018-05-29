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

test_that("badges can't contain an extra text", {
  expect_equal(
    badges_extract_text('<p><a href="url"><img src="img" alt="alt" /></a>Hi!</p>'),
    character()
  )
})

test_that("badges can be in special div", {
  expect_equal(
    badges_extract_text('<p></p><div id="badges"><a href="x"><img src="y"></a></div>'),
    '<a href="x"><img src="y"></a>'
  )
})
