# check_bootswatch_theme() works

    Can't find Bootswatch theme 'paper' (template.bootswatch) for Bootstrap version '4' (template.bootstrap).

# get_bs_version gives an informative error message

    Boostrap version must be 3 or 4.
    x You specified a value of 5 in template.bootstrap in '_pkgdown.yml'.

# pkgdown_footer() works by default

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<p>Developed by bla.</p>"
      
      $right
      [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\" class=\"external-link\">pkgdown</a> 42.</p>"
      

# pkgdown_footer() can use custom components

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<p>Developed by bla. <strong><em>Wow</em></strong></p>"
      
      $right
      [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\" class=\"external-link\">pkgdown</a> 42.</p>"
      

---

    Code
      pkgdown_footer(data, pkg)
    Output
      $left
      [1] "<p><strong><em>Wow</em></strong></p>"
      
      $right
      [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\" class=\"external-link\">pkgdown</a> 42.</p>"
      

# pkgdown_footer() throws informative error messages

    Can't find component footer.left.components.pof in '_pkgdown.yml'.

---

    Can't find component footer.right.components.bof in '_pkgdown.yml'.

