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
    

---

    reference:
      text: Reference
      href: reference/index.html
    github:
      icon: fab fa-gitlab fa-lg
      href: https://gitlab.com/r-lib/pkgdown
    

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
        - text: More...
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
      

# data_navbar()can remove elements

    Code
      data_navbar(pkg)
    Output
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>"
      
      $right
      [1] "<li>\n  <a href=\"reference/index.html\">Reference</a>\n</li>"
      

