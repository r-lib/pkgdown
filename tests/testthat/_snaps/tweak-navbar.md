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

