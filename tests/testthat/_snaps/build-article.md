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

# build_article yields useful error if pandoc fails

    Code
      build_article("test", pkg, pandoc_args = "--fail-if-warnings")
    Message
      Reading vignettes/test.Rmd
    Condition
      Error in `build_article()`:
      ! Failed to render 'vignettes/test.Rmd'.
      x [WARNING] This document format requires a nonempty <title> element.
      x  Defaulting to 'test.knit' as the title.
      x  To specify a title, use 'title' in metadata or --metadata title="...".
      x Failing because there were warnings.
      Caused by error:
      ! pandoc document conversion failed with error 3

# build_article yields useful error if R fails

    Code
      build_article("test", pkg)
    Message
      Reading vignettes/test.Rmd
    Condition
      Error in `build_article()`:
      ! Failed to render 'vignettes/test.Rmd'.
      x Quitting from lines 5-9 [unnamed-chunk-1] (test.Rmd)
      Caused by error:
      ! Error!

---

    Code
      summary(expect_error(build_article("test", pkg)))
    Message
      Reading vignettes/test.Rmd
    Output
      <error/rlang_error>
      Error in `build_article()`:
      ! Failed to render 'vignettes/test.Rmd'.
      x Quitting from lines 5-9 [unnamed-chunk-1] (test.Rmd)
      Caused by error:
      ! Error!
      ---
      Backtrace:
          x
       1. \-global f()
       2.   \-global g()
       3.     \-global h()

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

