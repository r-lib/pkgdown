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

# validates articles yaml

    Code
      data_articles_index_(1)
    Condition
      Error in `data_articles_index_()`:
      ! articles must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(1))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1] must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list()))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1] must have components "title" and "contents".
      2 missing components: "title" and "contents".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list(title = 1, contents = 1)))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1].title must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list(title = "a\n\nb", contents = 1)))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1].title must be inline markdown.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list(title = "a", contents = 1)))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1].contents[1] must be a string.
      i You might need to add '' around special YAML values like 'N' or 'off'
      i Edit _pkgdown.yml to fix the problem.

# validates external-articles

    Code
      data_articles_(1)
    Condition
      Error in `data_articles_()`:
      ! external-articles must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(1))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1] must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1] must have components "name", "title", "href", and "description".
      3 missing components: "title", "href", and "description".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = 1, title = "x", href = "x", description = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].name must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x", title = 1, href = "x", description = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].title must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x", title = "x", href = 1, description = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].href must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x", title = "x", href = "x", description = 1)))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].description must be a string, not the number 1.
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
      ! 'vignettes/bad-opengraph.Rmd': opengraph.twitter must be a list, not the number 1.

