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


# links -----------------------------------------------------------------

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

