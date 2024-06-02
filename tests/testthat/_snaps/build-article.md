# warns about missing images

    Code
      build_articles(pkg)
    Message
      -- Building articles -----------------------------------------------------------
      Writing `articles/index.html`
      Reading vignettes/kitten.Rmd
      Writing `articles/kitten.html`
      Missing images in 'vignettes/kitten.Rmd': 'kitten.jpg'
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
      i Learn more in `vignette(pkgdown::accessibility)`.

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
      ! In _pkgdown.yml, code.width must be a whole number, not the string "abc".

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
      ! In vignettes/bad-opengraph.Rmd, opengraph.twitter must be a list, not the number 1.

# render_rmarkdown copies image files in subdirectories

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
    Message
      Reading assets/vignette-with-img.Rmd
      Writing `test.html`

# render_rmarkdown yields useful error if pandoc fails

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = format)
    Message
      Reading assets/pandoc-fail.Rmd
    Condition
      Error:
      ! Failed to render 'assets/pandoc-fail.Rmd'.
      x [WARNING] Could not fetch resource path-to-image.png
      x Failing because there were warnings.
      Caused by error:
      ! pandoc document conversion failed with error 3

# render_rmarkdown yields useful error if R fails

    Code
      # Test traceback
      summary(expect_error(render_rmarkdown(pkg, "assets/r-fail.Rmd", "test.html")))
    Message
      Reading assets/r-fail.Rmd
    Output
      <error/rlang_error>
      Error:
      ! Failed to render 'assets/r-fail.Rmd'.
      x Quitting from lines 6-13 [unnamed-chunk-1] (r-fail.Rmd)
      Caused by error:
      ! Error!
      ---
      Backtrace:
          x
       1. \-global f()
       2.   \-global g()
       3.     \-global h()
    Code
      # Just test that it works; needed for browser() etc
      expect_error(render_rmarkdown(pkg, "assets/r-fail.Rmd", "test.html",
        new_process = FALSE))
    Message
      Reading assets/r-fail.Rmd
      
      Quitting from lines 6-13 [unnamed-chunk-1] (r-fail.Rmd)

# render_rmarkdown styles ANSI escapes

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")
    Message
      Reading assets/vignette-with-crayon.Rmd
      Writing `test.html`

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

