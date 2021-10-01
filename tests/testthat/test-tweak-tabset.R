
test_that("tweak_tabsets() default", {
  html <- '<div id="results-in-tabset" class="section level2 tabset">
<h2 class="hasAnchor">
<a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
<div id="tab-1" class="section level3">
<h3 class="hasAnchor">
<a href="#tab-1" class="anchor" aria-hidden="true"></a>Tab 1</h3>
<p>blablablabla</p>
<div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
<code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
</div>
<div id="tab-2" class="section level3">
<h3 class="hasAnchor">
<a href="#tab-2" class="anchor" aria-hidden="true"></a>Tab 2</h3>
<p>blop</p>
</div>
</div>'
  new_html <- tweak_tabsets(xml2::read_html(html))
  expect_snapshot_output(cat(as.character(new_html)))
})

test_that("tweak_tabsets() with tab pills and second tab active", {
  html <- '<div id="results-in-tabset" class="section level2 tabset tabset-pills">
<h2 class="hasAnchor">
<a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
<div id="tab-1" class="section level3">
<h3 class="hasAnchor">
<a href="#tab-1" class="anchor" aria-hidden="true"></a>Tab 1</h3>
<p>blablablabla</p>
<div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
<code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
</div>
<div id="tab-2" class="section level3 active">
<h3 class="hasAnchor">
<a href="#tab-2" class="anchor" aria-hidden="true"></a>Tab 2</h3>
<p>blop</p>
</div>
</div>'
  new_html <- tweak_tabsets(xml2::read_html(html))
  expect_snapshot_output(cat(as.character(new_html)))
})


test_that("tweak_tabsets() with tab pills, fade and second tab active", {
  html <- '<div id="results-in-tabset" class="section level2 tabset tabset-pills tabset-fade">
<h2 class="hasAnchor">
<a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
<div id="tab-1" class="section level3">
<h3 class="hasAnchor">
<a href="#tab-1" class="anchor" aria-hidden="true"></a>Tab 1</h3>
<p>blablablabla</p>
<div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
<code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
</div>
<div id="tab-2" class="section level3 active">
<h3 class="hasAnchor">
<a href="#tab-2" class="anchor" aria-hidden="true"></a>Tab 2</h3>
<p>blop</p>
</div>
</div>'
  new_html <- tweak_tabsets(xml2::read_html(html))
  expect_snapshot_output(cat(as.character(new_html)))
})
