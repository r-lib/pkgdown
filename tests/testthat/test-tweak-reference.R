test_that("tweak_reference_topic_html() works", {
  html <- xml2::read_html('
    <div class="ref-section">
      <div class="sourceCode r">
      <pre><code>1 + 1</code></pre>
      </div>
    </div>
  ')
  tweak_reference_topic_html(html)
  expect_snapshot_output(xpath_xml(html, "//pre"))

  html <- xml2::read_html('
    <div class="ref-section">
      <div class="sourceCode yaml">
        <pre><code>field: value</code></pre>
      </div>
    </div>
  ')
  tweak_reference_topic_html(html)
  expect_snapshot_output(xpath_xml(html, "//pre"))
})

test_that("works with unlabelled pre", {
  # If parseable, assume R
  html <- xml2::read_html('
    <div class="ref-section">
      <pre><code>foo()</code></pre>
    <div>
  ')
  tweak_reference_topic_html(html)
  expect_snapshot_output(xpath_xml(html, "//code"))

  # If not parseable, leave as is
  html <- xml2::read_html('
    <div class="ref-section">
      <pre><code>foo(</code></pre>
    <div>
  ')
  tweak_reference_topic_html(html)
  expect_snapshot_output(xpath_xml(html, "//code"))
})
