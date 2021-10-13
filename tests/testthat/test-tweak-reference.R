test_that("highlights <pre> wrapped in <div> with language info", {
  html <- xml2::read_html('
    <div class="ref-section">
      <div class="sourceCode r">
      <pre><code>1 + 2</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, "//code/span", "class"), c("fl", "op", "fl"))
  expect_equal(xpath_text(html, "//code/span"), c("1", "+", "2"))

  html <- xml2::read_html('
    <div class="ref-section">
      <div class="sourceCode yaml">
        <pre><code>field: value</code></pre>
      </div>
    </div>
  ')
  tweak_reference_highlighting(html)
  # pandoc adds an outer span for each line
  expect_equal(xpath_attr(html, "//code/span/span", "class"), c("fu", "kw", "at"))
  expect_equal(xpath_text(html, "//code/span/span"), c("field", ":", " value"))
})

test_that("highlight unwrapped <pre>", {
  # If parseable, assume R
  html <- xml2::read_html('
    <div class="ref-section">
      <pre><code>1 + 2</code></pre>
    <div>
  ')
  tweak_reference_highlighting(html)
  expect_equal(xpath_attr(html, "//code/span", "class"), c("fl", "op", "fl"))
  expect_equal(xpath_text(html, "//code/span"), c("1", "+", "2"))

  # If not parseable, leave as is
  html <- xml2::read_html('
    <div class="ref-section">
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

  expect_equal(xpath_attr(html, "//code/span/span", "class"), c("fu", "kw", "at"))
  expect_equal(xpath_text(html, "//code/span/span"), c("field", ":", " value"))
})

test_that("fails cleanly", {
  html <- xml2::read_xml('<div><pre><code></code></pre></div>')
  tweak_highlight_other(html)
  expect_equal(xpath_text(html, "//code"), "")

  html <- xml2::read_xml('<div><pre></pre></div>')
  expect_equal(tweak_highlight_other(html), FALSE)
})
