# works by default

    $left
    [1] "<p>Developed by First Last.</p>"
    
    $right
    [1] "<p>Site built with <a href=\"https://pkgdown.r-lib.org/\">pkgdown</a> {version}.</p>"
    

# validates meta components

    Code
      data_footer_(footer = 1)
    Condition
      Error in `data_footer_()`:
      ! In _pkgdown.yml, footer must be a list, not the number 1.
    Code
      data_footer_(footer = list(structure = 1))
    Condition
      Error in `data_footer_()`:
      ! In _pkgdown.yml, footer.structure must be a list, not the number 1.
    Code
      data_footer_(footer = list(components = 1))
    Condition
      Error in `data_footer_()`:
      ! In _pkgdown.yml, footer.components must be a list, not the number 1.
    Code
      data_footer_(authors = list(footer = list(roles = 1)))
    Condition
      Error in `data_footer_()`:
      ! In _pkgdown.yml, authors.footer.roles must be a character vector, not the number 1.
    Code
      data_footer_(authors = list(footer = list(text = 1)))
    Condition
      Error in `data_footer_()`:
      ! In _pkgdown.yml, authors.footer.text must be a string, not the number 1.

