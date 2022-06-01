# render_rmarkdown yields useful error

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html")
    Output
      Reading 'assets/pandoc-fail.Rmd'
      -- RMarkdown error -------------------------------------------------------------
      File path-to-image.png not found in resource path
      Error : pandoc document conversion failed with error 99
      --------------------------------------------------------------------------------
    Condition
      Error in `render_rmarkdown()`:
      ! Failed to render RMarkdown
      Caused by error:
      ! callr subprocess failed: pandoc document conversion failed with error 99
      Caused by error:
      ! pandoc document conversion failed with error 99

# render_rmarkdown styles ANSI escapes

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

