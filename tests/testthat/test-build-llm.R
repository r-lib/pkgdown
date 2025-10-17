test_that("integration test for convert_md()", {
  skip_if_no_pandoc()

  path <- withr::local_tempfile(pattern = "pkgdown-llm")
  convert_md(test_path("assets", "llm.html"), path)
  expect_snapshot(read_lines(path))
})

test_that("simplifies page header", {
  html <- xml2::read_html(
    r"(
      <main><div class="page-header">
        <img src="../logo.png" class="logo" alt=""><h1>Package index</h1>
      </div></main>)"
  )
  simplify_page_header(xml2::xml_find_first(html, ".//main"))
  expect_equal(xpath_contents(html, ".//main"), "<h1>Package index</h1>")
})

test_that("replaces lifecycle badges with strong text", {
  html <- xml2::read_html(
    r"(<span class="badge lifecycle lifecycle-deprecated">deprecated</span>)"
  )
  simplify_lifecycle_badges(html)
  expect_equal(xpath_contents(html, ".//body"), "<strong>deprecated</strong>")
})

test_that("converts internal urls to absolute with .md ending", {
  html <- xml2::read_html(
    r"(
      <a href="llm.html">link</a>
      <a href="#fragment">link</a>
      <a href="https://example.org">link</a>
    )"
  )
  create_absolute_links(html, "https://pkgdown.r-lib.org")
  expect_equal(
    xpath_attr(html, ".//a", "href"),
    c(
      "https://pkgdown.r-lib.org/llm.md",
      "#fragment",
      "https://example.org"
    )
  )
})

test_that("strip extra classes from pre", {
  html <- xml2::read_html(r"(<pre class="downlit sourceCode r">1+1</pre>)")
  simplify_code(html)
  expect_equal(xpath_attr(html, ".//pre", "class"), "r")
})
