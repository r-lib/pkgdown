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
        children:
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
        children:
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
        children:
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
        children:
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
      data_navbar(pkg)[c("left", "right")]
    Output
      $left
      [1] "<li class=\"nav-item\"><a class=\"nav-link\" href=\"https://github.com/r-lib/pkgdown/\" aria-label=\"GitHub\"><span class=\"fa fab fa-github fa-lg\"></span></a></li>\n<li class=\"nav-item\"><form class=\"form-inline\" role=\"search\">\n<input type=\"search\" class=\"form-control\" name=\"search-input\" id=\"search-input\" autocomplete=\"off\" aria-label=\"Search site\" placeholder=\"Search for\" data-search-index=\"search.json\">\n</form></li>"
      
      $right
      [1] "<li class=\"nav-item\"><a class=\"nav-link\" href=\"news/index.html\">Changelog</a></li>"
      

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
      ! navbar.structure.left must be a character vector, not the number 1.
      i Edit _pkgdown.yml to fix the problem.

# data_navbar() errors with bad left/right

    Code
      data_navbar(pkg)
    Condition
      Error in `data_template()`:
      ! navbar is incorrectly specified.
      i See details in `vignette(pkgdown::customise)`.
      i Edit _pkgdown.yml to fix the problem.

