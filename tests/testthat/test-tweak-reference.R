test_that("tweak_reference_topic_html() works", {
  html <- xml2::read_html('
    <div class="ref-section">
      <div class="sourceCode r">
      <pre><code>1 + 2</code></pre>
      </div>
    </div>
  ')
  tweak_reference_topic_html(html)
  expect_equal(xpath_attr(html, "//code/span", "class"), c("fl", "op", "fl"))
  expect_equal(xpath_text(html, "//code/span"), c("1", "+", "2"))

  html <- xml2::read_html('
    <div class="ref-section">
      <div class="sourceCode yaml">
        <pre><code>field: value</code></pre>
      </div>
    </div>
  ')
  tweak_reference_topic_html(html)
  # pandoc adds an outer span for each line
  expect_equal(xpath_attr(html, "//code/span/span", "class"), c("fu", "kw", "at"))
  expect_equal(xpath_text(html, "//code/span/span"), c("field", ":", " value"))
})

test_that("works with unlabelled pre", {
  # If parseable, assume R
  html <- xml2::read_html('
    <div class="ref-section">
      <pre><code>1 + 2</code></pre>
    <div>
  ')
  tweak_reference_topic_html(html)
  expect_equal(xpath_attr(html, "//code/span", "class"), c("fl", "op", "fl"))
  expect_equal(xpath_text(html, "//code/span"), c("1", "+", "2"))

  # If not parseable, leave as is
  html <- xml2::read_html('
    <div class="ref-section">
      <pre><code>foo(</code></pre>
    <div>
  ')
  tweak_reference_topic_html(html)
  expect_equal(xpath_length(html, "//code//span"), 0)
})
