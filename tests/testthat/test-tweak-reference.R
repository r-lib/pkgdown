test_that("highlights <pre> wrapped in <div> with language info", {
  skip_if_no_pandoc("2.16")

  withr::local_options(downlit.topic_index = c(foo = "foo"))
  html <- xml2::read_html('
    <div id="ref-section">
      <div class="sourceCode r">
      <pre><code>foo(x)</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, ".//code//a", "href"), "foo.html")

  # Or upper case R
  html <- xml2::read_html('
    <div id="ref-section">
      <div class="sourceCode R">
      <pre><code>foo(x)</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, ".//code//a", "href"), "foo.html")

  html <- xml2::read_html('
    <div id="ref-section">
      <div class="sourceCode yaml">
        <pre><code>field: value</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  # Select all leaf <span> to work around variations in pandoc styling
  expect_equal(xpath_attr(html, "//code//span[not(span)]", "class")[[1]], "fu")
  expect_equal(xpath_text(html, "//code//span[not(span)]")[[1]], "field")

  # But don't touch examples or usage
  html <- xml2::read_html('
    <div id="ref-examples">
      <div class="sourceCode R">
        <pre><code>foo(x)</code></pre>
      <div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_length(html, "//code//span"), 0)

  html <- xml2::read_html('
    <div id="ref-usage">
      <div class="sourceCode R">
        <pre><code>foo(x)</code></pre>
      <div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_length(html, "//code//span"), 0)
})

test_that("highlight unwrapped <pre>", {
  withr::local_options(downlit.topic_index = c(foo = "foo"))

  # If parseable, assume R
  html <- xml2::read_html('
    <div id="ref-sections">
      <pre><code>foo(x)</code></pre>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, ".//code//a", "href"), "foo.html")
  expect_equal(xpath_attr(html, ".//div/div", "class"), "sourceCode")

  # If not parseable, leave as is
  html <- xml2::read_html('
    <div id="ref-sections">
      <pre><code>foo(</code></pre>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_length(html, "//code//span"), 0)
  expect_equal(xpath_attr(html, ".//div/div", "class"), "sourceCode")
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
  skip_if_no_pandoc("2.16")
  html <- xml2::read_xml('<div class="yaml"><pre><code>field: value</code></pre></div>')
  tweak_highlight_other(html)

  # Select all leaf <span> to work around variations in pandoc styling
  expect_equal(xpath_attr(html, "//code//span[not(span)]", "class")[[1]], "fu")
  expect_equal(xpath_text(html, "//code//span[not(span)]")[[1]], "field")
})

test_that("fails cleanly", {
  html <- xml2::read_xml('<div><pre><code></code></pre></div>')
  tweak_highlight_other(html)
  expect_equal(xpath_text(html, "//code"), "")

  html <- xml2::read_xml('<div><pre></pre></div>')
  expect_equal(tweak_highlight_other(html), FALSE)
})
