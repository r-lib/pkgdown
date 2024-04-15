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
      x Failed to render RMarkdown document.
        [WARNING] Could not fetch resource path-to-image.png
        Failing because there were warnings.
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
      x Failed to render RMarkdown document.
        
        Quitting from lines 6-13 [unnamed-chunk-1] (r-fail.Rmd)
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

