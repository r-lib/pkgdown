# adds github/gitlab link when available

    reference:
      text: Reference
      href: reference/index.html
    

---

    reference:
      text: Reference
      href: reference/index.html
    github:
      icon: fab fa-github fa-lg
      href: https://github.com/r-lib/pkgdown
      aria-label: github
    

---

    reference:
      text: Reference
      href: reference/index.html
    github:
      icon: fab fa-gitlab fa-lg
      href: https://gitlab.com/r-lib/pkgdown
      aria-label: gitlab
    

# vignette with package name turns into getting started

    reference:
      text: Reference
      href: reference/index.html
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
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"reference/index.html\">Reference</a>\n</li>\n<li>\n  <a href=\"news/index.html\">Changelog</a>\n</li>"
      
      $right
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>"
      

# data_navbar() can re-order default elements

    Code
      data_navbar(pkg)
    Output
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>\n<li>\n  <a href=\"reference/index.html\">Reference</a>\n</li>"
      
      $right
      [1] "<li>\n  <a href=\"news/index.html\">Changelog</a>\n</li>"
      

# data_navbar() can remove elements

    Code
      data_navbar(pkg)
    Output
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>"
      
      $right
      [1] ""
      

# data_navbar() works with empty side

    Code
      data_navbar(pkg)
    Output
      $type
      [1] "default"
      
      $left
      [1] ""
      
      $right
      [1] ""
      

# data_navbar() errors with bad side specifications

    Code
      data_navbar(pkg)
    Condition
      Error in `navbar_links()`:
      ! navbar.structure.left must be a character vector.

# data_navbar() errors with bad left/right

    Code
      data_navbar(pkg)
    Condition
      Error in `data_template()`:
      ! Invalid navbar specification in _pkgdown.yml

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
      <li class="nav-item">
        <a class="nav-link" href="articles/pkgdown.html">Get started</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="reference/index.html">Reference</a>
      </li>
      <li class="nav-item dropdown">
        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true" id="dropdown-articles">Articles</a>
        <div class="dropdown-menu" aria-labelledby="dropdown-articles">
          <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
          <a class="dropdown-item" href="articles/search.html">Search</a>
          <a class="dropdown-item" href="articles/metadata.html">Metadata</a>
          <a class="dropdown-item" href="articles/customization.html">Customize your pkgdown website</a>
          <div class="dropdown-divider"></div>
          <a class="dropdown-item" href="articles/index.html">More...</a>
        </div>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="news/index.html">News</a>
      </li>

# render_navbar_links BS4 no divider before first element

    Code
      cat(render_navbar_links(x, pkg = list(bs_version = 4)))
    Output
      <li class="nav-item dropdown">
        <a href="#" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true" id="dropdown-articles">Articles</a>
        <div class="dropdown-menu" aria-labelledby="dropdown-articles">
          <h6 class="dropdown-header" data-toc-skip>First section</h6>
          <a class="dropdown-item" href="articles/search.html">Search</a>
          <a class="dropdown-item" href="articles/metadata.html">Metadata</a>
          <a class="dropdown-item" href="articles/customization.html">Customize your pkgdown website</a>
          <div class="dropdown-divider"></div>
          <a class="dropdown-item" href="articles/index.html">More...</a>
        </div>
      </li>

# can specific link target

    Code
      bs4_navbar_links_tags(list(menu = list(text = "text", href = "href", target = "_blank")))
    Output
      <li class="nav-item">
        <a class="nav-link" href="href" target="_blank">text</a>
      </li>
    Code
      bs4_navbar_links_tags(list(menu = list(text = "text", href = "href", target = "_blank")),
      depth = 1)
    Output
      <a class="dropdown-item" href="href" target="_blank">text</a>

