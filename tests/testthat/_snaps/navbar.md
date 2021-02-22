# check_missing_nav_links()

    Code
      check_missing_nav_links(c(reference = "bla", news = "blop"), "news", pkg)
    Warning <warning>
      Component reference is not included in navbar.structure in '_pkgdown.yml'.

---

    Code
      check_missing_nav_links(c(reference = "bla", news = "blop", articles = "pof"),
      "news", pkg)
    Warning <warning>
      Components reference, articles are not included in navbar.structure in '_pkgdown.yml'.

# data_navbar()

    Code
      data_navbar(pkg)
    Output
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"reference/index.html\">Reference</a>\n</li>\n<li>\n  <a href=\"news/index.html\">Changelog</a>\n</li>"
      
      $right
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>"
      

---

    Code
      data_navbar(pkg)
    Output
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>\n<li>\n  <a href=\"reference/index.html\">Reference</a>\n</li>"
      
      $right
      [1] "<li>\n  <a href=\"news/index.html\">Changelog</a>\n</li>"
      

---

    Code
      data_navbar(pkg)
    Warning <warning>
      Component reference is not included in navbar.structure in '_pkgdown.yml'.
    Output
      $type
      [1] "default"
      
      $left
      [1] "<li>\n  <a href=\"https://github.com/r-lib/pkgdown/\">\n    <span class=\"fab fa-github fa-lg\"></span>\n     \n  </a>\n</li>"
      
      $right
      [1] "<li>\n  <a href=\"news/index.html\">Changelog</a>\n</li>"
      

