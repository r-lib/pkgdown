test_that("ensure templates have expected div", {
  html3 <- read_template_html("content", "reference-topic", bs_version = 3)
  expect_equal(length(find_ref_sections(html3)), 1)

  html5 <- read_template_html("content", "reference-topic", bs_version = 5)
  expect_equal(length(find_ref_sections(html5)), 1)
})

test_that("highlights <pre> wrapped in <div> with language info", {
  withr::local_options(downlit.topic_index = c(foo = "foo"))
  html <- xml2::read_html('
    <div id="ref-sections">
      <div class="sourceCode r">
      <pre><code>foo(x)</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, ".//code//a", "href"), "foo.html")

  # Or upper case R
  html <- xml2::read_html('
    <div id="ref-sections">
      <div class="sourceCode R">
      <pre><code>foo(x)</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, ".//code//a", "href"), "foo.html")

  html <- xml2::read_html('
    <div id="ref-sections">
      <div class="sourceCode yaml">
        <pre><code>field: value</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  # Select all leaf <span> to work around variations in pandoc styling
  expect_equal(xpath_attr(html, "//code//span[not(span)]", "class"), c("fu", "kw", "at"))
  expect_equal(xpath_text(html, "//code//span[not(span)]"), c("field", ":", " value"))
})

test_that("highlight unwrapped <pre>", {
  withr::local_options(downlit.topic_index = c(foo = "foo"))

  # If parseable, assume R
  html <- xml2::read_html('
    <div id="ref-sections">
      <pre><code>foo(x)</code></pre>
    <div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, ".//code//a", "href"), "foo.html")

  # If not parseable, leave as is
  html <- xml2::read_html('
    <div id="ref-sections">
      <pre><code>foo(</code></pre>
    <div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_length(html, "//code//span"), 0)
})


# highlighting ------------------------------------------------------------

test_that("can highlight R code", {
  html <- xml2::read_xml('<div><pre><code>1 + 2</code></pre></div>')
  tweak_highlight_r(html)

  expect_equal(xpath_attr(html, "//code/span", "class"), c("fl", "op", "fl"))
  expect_equal(xpath_text(html, "//code/span"), c("1", "+", "2"))
})

test_that("fails cleanly", {
  html <- xml2::read_xml('<div><pre><code>1 + </code></pre></div>')
  expect_equal(tweak_highlight_r(html), FALSE)

  html <- xml2::read_xml('<div><pre><code></code></pre></div>')
  expect_equal(tweak_highlight_r(html), FALSE)

  html <- xml2::read_xml('<div><pre></pre></div>')
  expect_equal(tweak_highlight_r(html), FALSE)
})

test_that("can highlight other languages", {
  html <- xml2::read_xml('<div class="yaml"><pre><code>field: value</code></pre></div>')
  tweak_highlight_other(html)

  # Select all leaf <span> to work around variations in pandoc styling
  expect_equal(xpath_attr(html, "//code//span[not(span)]", "class"), c("fu", "kw", "at"))
  expect_equal(xpath_text(html, "//code//span[not(span)]"), c("field", ":", " value"))
})

test_that("fails cleanly", {
  html <- xml2::read_xml('<div><pre><code></code></pre></div>')
  tweak_highlight_other(html)
  expect_equal(xpath_text(html, "//code"), "")

  html <- xml2::read_xml('<div><pre></pre></div>')
  expect_equal(tweak_highlight_other(html), FALSE)
})
