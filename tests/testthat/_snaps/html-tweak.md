# anchors don't get additional newline

    <div class="contents">
      <div id="x">
        <h1>abc</h1>
      </div>
    </div>

# tweak_404() make URLs absolute

    Code
      cat(as.character(xml2::xml_child(prod_html)))
    Output
      <body><div><div><div>
          <a href="https://example.com/reference.html"></a>
          <link href="https://example.com/reference.css">
      <script src="https://example.com/reference.js"></script><img src="https://example.com/" class="pkg-logo">
      </div></div></div></body>

---

    Code
      cat(as.character(xml2::xml_child(dev_html)))
    Output
      <body><div><div><div>
          <a href="https://example.com/reference.html"></a>
          <link href="https://example.com/reference.css">
      <script src="https://example.com/reference.js"></script><img src="https://example.com/" class="pkg-logo">
      </div></div></div></body>

# page header modification succeeds

    <h1 class="hasAnchor"><a href="#plot" class="anchor"> </a><img src="someimage" alt=""/> some text
        </h1>

# links to vignettes & figures tweaked

    <body>
      <img src="articles/x.png"/>
      <img src="reference/figures/x.png"/>
    </body>

# navbar_links_haystack()

    Code
      navbar_links_haystack(html(), pkg = list(), path = "articles/bla.html")[, c(
        "links", "similar")]
    Output
      # A tibble: 1 x 2
        links    similar
        <chr>      <dbl>
      1 articles       1

---

    Code
      navbar_links_haystack(html(), pkg = list(), path = "articles/linking.html")[, c(
        "links", "similar")]
    Output
      # A tibble: 2 x 2
        links                 similar
        <chr>                   <dbl>
      1 articles/linking.html       2
      2 articles                    1

---

    Code
      navbar_links_haystack(html(), pkg = list(), path = "articles/pkgdown.html")[, c(
        "links", "similar")]
    Output
      # A tibble: 2 x 2
        links                 similar
        <chr>                   <dbl>
      1 articles/pkgdown.html       2
      2 articles                    1

# activate_navbar()

    {html_node}
    <li class="active nav-item">
    [1] <a class="nav-link" href="reference/index.html">Reference</a>

---

    {html_node}
    <li class="active nav-item">
    [1] <a class="nav-link" href="reference/index.html">Reference</a>

---

    {html_node}
    <li class="active nav-item">
    [1] <a class="nav-link" href="articles/pkgdown.html">Get started</a>

---

    {html_node}
    <li class="active nav-item dropdown">
    [1] <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role= ...
    [2] <div class="dropdown-menu" aria-labelledby="navbarDropdown">\n    <a clas ...

# tweak_tabsets() default

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-tabs nav-row" id="results-in-tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="active nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="false" class="nav-link">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="active tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

# tweak_tabsets() with tab pills and second tab active

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset tabset-pills">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-pills nav-row" id="results-in-tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="true" class="nav-link active">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="active tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

# tweak_tabsets() with tab pills, fade and second tab active

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset tabset-pills tabset-fade">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-pills nav-row" id="results-in-tabset" role="tablist">
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-1" role="tab" aria-controls="tab-1" aria-selected="false" class="nav-link">Tab 1</a></li>
    <li role="presentation" class="nav-item"><a data-toggle="tab" href="#tab-2" role="tab" aria-controls="tab-2" aria-selected="true" class="nav-link active">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="fade tab-pane" role="tabpanel"  aria-labelledby="tab-1">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="show active fade tab-pane" role="tabpanel"  aria-labelledby="tab-2">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

# tweak_reference_topic_html() works

    <body>
      <div class="ref-section">
      <div class="sourceCode r">
      <pre>
      <code><span class="fu">rlang</span><span class="fu">::</span><span class="fu"><a href="https://rlang.r-lib.org/reference/is_installed.html">is_installed</a></span><span class="op">(</span><span class="op">)</span></code>
      </pre>
      </div>
      </div>
      </body>

---

    <body>
      <div class="ref-section">
      <pre>
      <code><span class="fu">rlang</span><span class="fu">::</span><span class="fu"><a href="https://rlang.r-lib.org/reference/is_installed.html">is_installed</a></span><span class="op">(</span><span class="op">)</span></code>
      </pre>
      </div>
      </body>

---

    <body>
      <div class="ref-section">
      <div class="sourceCode yaml">
      <pre>
      <code><span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a></span>
    <span id="cb1-2"><a href="#cb1-2" aria-hidden="true" tabindex="-1"></a><span class="at">  </span><span class="fu">url</span><span class="kw">:</span><span class="at"> https://pkgdown.r-lib.org/</span></span>
    <span id="cb1-3"><a href="#cb1-3" aria-hidden="true" tabindex="-1"></a></span>
    <span id="cb1-4"><a href="#cb1-4" aria-hidden="true" tabindex="-1"></a><span class="at">  </span></span></code>
      </pre>
      </div>
      </div>
      </body>

