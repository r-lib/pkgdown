# pkgdown_footer() works by default

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<p>Developed by bla.</p>"
      
      $right
      [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\">pkgdown</a> 42.</p>"
      

# pkgdown_footer() can use custom components

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<p>Developed by bla. <strong><em>Wow</em></strong></p>"
      
      $right
      [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\">pkgdown</a> 42.</p>"
      

---

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<p><strong><em>Wow</em></strong></p>"
      
      $right
      [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\">pkgdown</a> 42.</p>"
      

# pkgdown_footer() throws informative error messages

    Can't find component footer.left.components.pof in '_pkgdown.yml'.

---

    Can't find component footer.right.components.bof in '_pkgdown.yml'.

