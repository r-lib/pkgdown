# bad width gives nice error

    Code
      rmarkdown_setup_pkgdown(pkg)
    Condition
      Error in `rmarkdown_setup_pkgdown()`:
      ! In _pkgdown.yml, code.width must be a whole number, not the string "abc".

# output is reproducible by default, i.e. 'seed' is respected

    Code
      cat(output)
    Output
      ## [1] 0.080750138 0.834333037 0.600760886 0.157208442 0.007399441

# reports on bad open graph meta-data

    Code
      build_article("test", pkg)
    Message
      Reading vignettes/test.Rmd
    Condition
      Error in `build_article()`:
      ! In vignettes/test.Rmd, opengraph.twitter must be a list, not the number 1.

# build_article styles ANSI escapes

    <span class="co">## <span style="color: #BB0000;">X</span></span>

# build_article copies image files in subdirectories

    Code
      build_article("test", pkg)
    Message
      Reading vignettes/test.Rmd
      Writing `articles/test.html`

# warns about missing images

    Code
      build_article("kitten", pkg)
    Message
      Reading vignettes/kitten.Rmd
      Writing `articles/kitten.html`
      Missing images in 'vignettes/kitten.Rmd': 'kitten.jpg'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing alt-text

    Code
      build_article("kitten", pkg)
    Message
      Reading vignettes/kitten.Rmd
      Writing `articles/kitten.html`
      x Missing alt-text in 'vignettes/kitten.Rmd'
      * kitten.jpg
      i Learn more in `vignette(pkgdown::accessibility)`.

