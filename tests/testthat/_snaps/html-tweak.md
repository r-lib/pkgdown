# anchors don't get additional newline

    <div class="contents">
      <div id="x">
        <h1>abc</h1>
      </div>
    </div>

# page header modification succeeds

    <h1 class="hasAnchor"><a href="#plot" class="anchor"> </a><img src="someimage" alt=""/> some text
        </h1>

# links to vignettes & figures tweaked

    <body>
      <img src="articles/x.png"/>
      <img src="reference/figures/x.png"/>
    </body>

# navbar_links_haystack()

    # A tibble: 4 x 2
      nav_item   links                
      <list>     <chr>                
    1 <xml_node> articles/pkgdown.html
    2 <xml_node> reference            
    3 <xml_node> articles/linking.html
    4 <xml_node> articles             

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

