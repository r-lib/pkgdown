# tables -------------------------------------------------------------

test_that("tables get additional table class", {
  html <- xml2::read_html("
    <body>
      <table></table>
      <table class='a'></table>
      <table class='b'></table>
      </body>
  ")
  tweak_tables(html)

  expect_equal(
    xpath_attr(html, ".//table", "class"),
    c("table", "table a", "table b")
  )
})

# anchors -------------------------------------------------------------

test_that("ids move from div to headings", {
  html <- xml2::read_xml('<body>
    <div id="1"><h1>abc</h1></div>
    <div id="2"><h2>abc</h2></div>
    <div id="3"><h3>abc</h3></div>
    <div id="4"><h4>abc</h4></div>
    <div id="5"><h5>abc</h5></div>
    <div id="6"><h6>abc</h6></div>
  </body>')
  tweak_anchors(html)
  expect_equal(xpath_attr(html, ".//h1|//h2|//h3|//h4|//h5|//h6", "id"), as.character(1:6))
  expect_equal(xpath_attr(html, ".//div", "id"), rep(NA_character_, 6))
})

test_that("anchor html added to headings", {
  html <- xml2::read_xml('<body><div id="x"><h1>abc</h1></div></body>')
  tweak_anchors(html)
  expect_snapshot_output(xpath_xml(html, ".//h1"))
})

test_that("deduplicates ids", {
  html <- xml2::read_xml('<body>
      <div id="x"><h1>abc</h1></div>
      <div id="x"><h1>abc</h1></div>
      <div id="x"><h1>abc</h1></div>
    </body>
  ')
  tweak_anchors(html)
  expect_equal(xpath_attr(html, ".//h1", "id"), c("x", "x-1", "x-2"))
})

test_that("can process multiple header levels", {
  html <- xml2::read_xml('<div>
      <div id="1"><h1>abc</h1></div>
      <div id="2"><h2>abc</h2></div>
      <div id="3"><h3>abc</h3></div>
      <div id="4"><h4>abc</h4></div>
    </div>
  ')
  tweak_anchors(html)
  expect_equal(xpath_attr(html, ".//a", "href"), c("#1", "#2", "#3", "#4"))
})

test_that("only modifies first header", {
  html <- xml2::read_xml('<body><div id="x"><h1>one</h1><h1>two</h1></div></body>')
  tweak_anchors(html)
  expect_equal(xpath_length(html, ".//h1/a"), 1)
})

test_that("anchors don't get additional newline", {
  html <- xml2::read_xml('<div id="x"><h1>abc</h1></div>')
  tweak_anchors(html)
  expect_equal(xpath_text(html, ".//h1"), "abc")
})

test_that("empty headings are skipped", {
  html <- xml2::read_xml('<div id="x"><h1></h1></div>')
  tweak_anchors(html)
  expect_equal(xpath_length(html, ".//h1/a"), 0)
})

test_that("docs with no headings are left unchanged", {
  html <- xml2::read_xml('<div>Nothing</div>')
  tweak_anchors(html)
  expect_equal(as.character(xpath_xml(html, ".")), '<div>Nothing</div>')
})

# links -----------------------------------------------------------------

test_that("local md links are replaced with html", {
  html <- xml2::read_html('
    <a href="local.md"></a>
    <a href="http://remote.com/remote.md"></a>
  ')
  tweak_link_md(html)

  expect_equal(
    xpath_attr(html, "//a", "href"),
    c("local.html", "http://remote.com/remote.md")
  )
})

test_that("tweak_link_external() add the external-link class", {
  html <- xml2::read_html('
    <a href="#anchor"></a>
    <a href="http://remote.com/remote.md"></a>
    <a class = "thumbnail" href="http://remote.com/remote.md"></a>
    <a href="http://example.com/remote.md"></a>
  ')

  pkg <- list(meta = list(url = "http://example.com"))
  tweak_link_external(html, pkg = pkg)

  expect_equal(
    xpath_attr(html, "//a", "class"),
    c(NA, "external-link", "external-link thumbnail", NA)
  )
})

test_that("tweak_link_absolute() fixes relative paths in common locations", {
  html <- xml2::read_html('
    <a href="a"></a>
    <link href="link"></link>
    <script src="script"></script>
    <img src="img">
  ')
  pkg <- list(meta = list(url = "https://example.com"))
  tweak_link_absolute(html, pkg)

  expect_equal(xpath_attr(html, "//a", "href"), "https://example.com/a")
  expect_equal(xpath_attr(html, "//link", "href"), "https://example.com/link")
  expect_equal(xpath_attr(html, "//img", "src"), "https://example.com/img")
})

test_that("tweak_link_absolute() leaves absolute paths alone", {
  html <- xml2::read_html('<a href="https://a.com"></a>')
  pkg <- list(list(url = "https://example.com"))
  tweak_link_absolute(html, pkg)

  expect_equal(xpath_attr(html, "//a", "href"), "https://a.com")
})


test_that("tweak_link_r6() correctly modifies link to inherited R6 classes", {
  skip_on_cran() # in case downlit url changes
  html <- xml2::read_html("
    <span class=\"pkg-link\" data-pkg=\"pkgdown\" data-topic=\"Animal\" data-id=\"x\">
      <a href='replace-me.html'>text</a>
    </span>
    <span>
      <a href='leave-me.html'>text</a>
    </span>
    <span class=\"pkg-link\" data-pkg=\"downlit\" data-topic=\"autolink_url\" data-id=\"x\">
      <a href='replace_me.html'>text</a>
    </span>
  ")

  tweak_link_R6(html, "pkgdown")
  expect_equal(
    xpath_attr(html, "//a", "href"),
    c(
      "Animal.html#method-x",
      "leave-me.html",
      "https://downlit.r-lib.org/reference/autolink.html#method-x"
    )
  )
})
