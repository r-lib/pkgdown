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
    
    
    <ul class="nav nav-tabs nav-row" id="results-in-tabset">
    <li class="active "><a data-toggle="tab" href="#tab-1" role="tab">Tab 1</a></li>
    <li class=""><a data-toggle="tab" href="#tab-2" role="tab">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="active tab-pane" role="tabpanel">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="tab-pane" role="tabpanel">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

# tweak_tabsets() with tab pills and second tab active

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
    <html><body><div id="results-in-tabset" class="section level2 tabset tabset-pills">
    <h2 class="hasAnchor">
    <a href="#results-in-tabset" class="anchor" aria-hidden="true"></a>Results in tabset</h2>
    
    
    <ul class="nav nav-pills nav-row" id="results-in-tabset">
    <li class=""><a data-toggle="tab" href="#tab-1" role="tab">Tab 1</a></li>
    <li class="active"><a data-toggle="tab" href="#tab-2" role="tab">Tab 2</a></li>
    </ul>
    <div class="tab-content">
    <div id="tab-1" class="tab-pane" role="tabpanel">
    
    <p>blablablabla</p>
    <div class="sourceCode" id="cb9"><pre class="downlit sourceCode r">
    <code class="sourceCode R"><span class="fl">1</span> <span class="op">+</span> <span class="fl">1</span></code></pre></div>
    </div>
    <div id="tab-2" class="active tab-pane" role="tabpanel">
    
    <p>blop</p>
    </div>
    </div>
    </div></body></html>

