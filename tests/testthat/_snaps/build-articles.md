# warns about missing images

    Code
      build_articles(pkg)
    Message
      -- Building articles -----------------------------------------------------------
      Writing `articles/index.html`
      Reading vignettes/html-vignette.Rmd
      Writing `articles/html-vignette.html`
      Missing images in 'vignettes/html-vignette.Rmd': 'kitten.jpg'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing alt-text

    Code
      build_article("missing-images", pkg)
    Message
      Reading vignettes/missing-images.Rmd
      Writing `articles/missing-images.html`
      x Missing alt-text in 'vignettes/missing-images.Rmd'
      * kitten.jpg
      * missing-images_files/figure-html/unnamed-chunk-1-1.png
      i Learn more in `vignette(accessibility)`.

# can build article that uses html_vignette

    Code
      expect_error(build_article("html-vignette", pkg), NA)
    Message
      Reading vignettes/html-vignette.Rmd
      Writing `articles/html-vignette.html`

# bad width gives nice error

    Code
      build_rmarkdown_format(pkg, "article")
    Condition
      Error in `build_rmarkdown_format()`:
      ! code.width must be a whole number, not the string "abc".
      i Edit _pkgdown.yml to fix the problem.

# articles in vignettes/articles/ are unnested into articles/

    Code
      build_redirects(pkg)
    Message
      -- Building redirects ----------------------------------------------------------
      Adding redirect from articles/articles/nested.html to articles/nested.html.

# warns about articles missing from index

    Code
      . <- data_articles_index(pkg)
    Condition
      Error:
      ! 1 vignette missing from index: "c".
      i Edit _pkgdown.yml to fix the problem.

# output is reproducible by default, i.e. 'seed' is respected

    Code
      cat(output)
    Output
      ## [1] 0.080750138 0.834333037 0.600760886 0.157208442 0.007399441

# reports on bad open graph meta-data

    Code
      build_article(pkg = pkg, name = "bad-opengraph")
    Condition
      Error in `build_article()`:
      ! Can't find article 'bad-opengraph'

