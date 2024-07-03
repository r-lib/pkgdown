# adds github/gitlab link when available

    reference:
      text: Reference
      href: reference/index.html
    search:
      search: []
    

---

    reference:
      text: Reference
      href: reference/index.html
    search:
      search: []
    github:
      icon: fab fa-github fa-lg
      href: https://github.com/r-lib/pkgdown
      aria-label: GitHub
    

---

    reference:
      text: Reference
      href: reference/index.html
    search:
      search: []
    github:
      icon: fab fa-gitlab fa-lg
      href: https://gitlab.com/r-lib/pkgdown
      aria-label: GitLab
    

# vignette with package name turns into getting started

    reference:
      text: Reference
      href: reference/index.html
    search:
      search: []
    intro:
      text: Get started
      href: test.html
    

# can control articles navbar through articles meta

    Code
      navbar_articles(pkg())
    Output
      articles:
        text: Articles
        menu:
        - text: Title a
          href: a.html
        - text: Title b
          href: b.html
      

---

    Code
      navbar_articles(pkg(articles = list(list(name = "all", contents = c("a", "b")))))
    Output
      articles:
        text: Articles
        href: articles/index.html
      

---

    Code
      navbar_articles(pkg(articles = list(list(name = "all", contents = c("a", "b"),
      navbar = NULL))))
    Output
      articles:
        text: Articles
        menu:
        - text: Title a
          href: a.html
        - text: Title b
          href: b.html
      

---

    Code
      navbar_articles(pkg(articles = list(list(name = "all", contents = c("a", "b"),
      navbar = "Label"))))
    Output
      articles:
        text: Articles
        menu:
        - text: '---------'
        - text: Label
        - text: Title a
          href: a.html
        - text: Title b
          href: b.html
      

---

    Code
      navbar_articles(pkg(articles = list(list(name = "a", contents = "a", navbar = NULL),
      list(name = "b", contents = "b"))))
    Output
      articles:
        text: Articles
        menu:
        - text: Title a
          href: a.html
        - text: '---------'
        - text: More articles...
          href: articles/index.html
      

# data_navbar() works by default

    Code
      data_navbar(pkg)
    Output
      $bg
      [1] "light"
      
      $type
      [1] "light"
      
      $left
      [1] "<li class=\"nav-item\"><a class=\"nav-link\" href=\"reference/index.html\">Reference</a></li>\n<li class=\"nav-item\"><a class=\"nav-link\" href=\"news/index.html\">Changelog</a></li>"
      
      $right
      [1] "<li class=\"nav-item\"><form class=\"form-inline\" role=\"search\">\n <input class=\"form-control\" type=\"search\" name=\"search-input\" id=\"search-input\" autocomplete=\"off\" aria-label=\"Search site\" placeholder=\"Search for\" data-search-index=\"search.json\"> \n</form></li>\n<li class=\"nav-item\"><a class=\"nav-link\" href=\"https://github.com/r-lib/pkgdown/\" aria-label=\"GitHub\"><span class=\"fa fab fa-github fa-lg\"></span></a></li>"
      

# data_navbar() can re-order default elements

    Code
      data_navbar(pkg)[c("left", "right")]
    Output
      $left
      [1] "<li class=\"nav-item\"><a class=\"nav-link\" href=\"https://github.com/r-lib/pkgdown/\" aria-label=\"GitHub\"><span class=\"fa fab fa-github fa-lg\"></span></a></li>\n<li class=\"nav-item\"><form class=\"form-inline\" role=\"search\">\n <input class=\"form-control\" type=\"search\" name=\"search-input\" id=\"search-input\" autocomplete=\"off\" aria-label=\"Search site\" placeholder=\"Search for\" data-search-index=\"search.json\"> \n</form></li>"
      
      $right
      [1] "<li class=\"nav-item\"><a class=\"nav-link\" href=\"news/index.html\">Changelog</a></li>"
      

# data_navbar() works with empty side

    Code
      data_navbar(pkg)
    Output
      $bg
      [1] "light"
      
      $type
      [1] "light"
      
      $left
      [1] ""
      
      $right
      [1] ""
      

# data_navbar_() errors with bad yaml specifications

    Code
      data_navbar_(navbar = list(structure = list(left = 1)))
    Condition
      Error in `data_navbar_()`:
      ! In _pkgdown.yml, navbar.structure.left must be a character vector, not the number 1.
    Code
      data_navbar_(navbar = list(right = "github"))
    Condition
      Error in `data_template()`:
      ! In _pkgdown.yml, navbar is incorrectly specified.
      i See details in `vignette(pkgdown::customise)`.

# render_navbar_links BS3 & BS4 default

    Code
      cat(render_navbar_links(x, pkg = list(bs_version = 3)))
    Output
      <li>
        <a href="articles/pkgdown.html">Get started</a>
      </li>
      <li>
        <a href="reference/index.html">Reference</a>
      </li>
      <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
          Articles
           
          <span class="caret"></span>
        </a>
        <ul class="dropdown-menu" role="menu">
          <li>
            <a href="articles/linking.html">Auto-linking</a>
          </li>
          <li>
            <a href="articles/search.html">Search</a>
          </li>
          <li>
            <a href="articles/metadata.html">Metadata</a>
          </li>
          <li>
            <a href="articles/customization.html">Customize your pkgdown website</a>
          </li>
          <li class="divider"></li>
          <li>
            <a href="articles/index.html">More...</a>
          </li>
        </ul>
      </li>
      <li>
        <a href="news/index.html">News</a>
      </li>

---

    Code
      cat(render_navbar_links(x, pkg = list(bs_version = 4)))
    Output
      <li class="nav-item"><a class="nav-link" href="articles/pkgdown.html">Get started</a></li>
      <li class="nav-item"><a class="nav-link" href="reference/index.html">Reference</a></li>
      <li class="nav-item dropdown">
        <button class="nav-link dropdown-toggle" type="button" id="dropdown-articles" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true">Articles</button>
        <ul class="dropdown-menu" aria-labelledby="dropdown-articles">
          <li><a class="dropdown-item" href="articles/linking.html">Auto-linking</a></li>
          <li><a class="dropdown-item" href="articles/search.html">Search</a></li>
          <li><a class="dropdown-item" href="articles/metadata.html">Metadata</a></li>
          <li><a class="dropdown-item" href="articles/customization.html">Customize your pkgdown website</a></li>
          <li><hr class="dropdown-divider"></li>
          <li><a class="dropdown-item" href="articles/index.html">More...</a></li>
        </ul>
      </li>
      <li class="nav-item"><a class="nav-link" href="news/index.html">News</a></li>

