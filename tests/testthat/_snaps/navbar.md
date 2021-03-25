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
      

