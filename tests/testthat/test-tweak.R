context("tweak")

test_that("tables get class='table'", {
  html <- xml2::read_html("<body><table>\n</table></body>")
  tweak_tables(html)

  html %>%
    xml2::xml_find_all(".//table") %>%
    xml2::xml_attr("class") %>%
     expect_equal("table")
})

test_that("anchors don't get additional newline", {
  html <- xml2::read_html('<div class="contents">
      <div id="x">
        <h1>abc</h1>
      </div>
    </div>')

  tweak_anchors(html)

  expect_output_file(
    html %>% xml2::xml_find_first(".//h1") %>% as.character() %>% cat(),
    "tweak-anchor.html", update = TRUE
  )
})

test_that("Stripping HTML tags", {
    expect_identical(strip_html_tags("<p>some text about <code>data</code>"),
        "some text about data")
})
