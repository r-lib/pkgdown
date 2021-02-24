# pkgdown_footer() works by default

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "Developed by bla."
      
      $right
      [1] "Site built with <a href=\"https://pkgdown.r-lib.org/\" class=\"external-link\">pkgdown</a> 42."
      

# pkgdown_footer() can use custom components

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "Developed by bla. <strong><em>Wow</em></strong>"
      
      $right
      [1] "Site built with <a href=\"https://pkgdown.r-lib.org/\" class=\"external-link\">pkgdown</a> 42."
      

---

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<strong><em>Wow</em></strong>"
      
      $right
      [1] "Site built with <a href=\"https://pkgdown.r-lib.org/\" class=\"external-link\">pkgdown</a> 42."
      

# pkgdown_footer() throws informative error messages

    Can't find component footer.left.components.pof in '_pkgdown.yml'.

---

    Can't find component footer.right.components.bof in '_pkgdown.yml'.

