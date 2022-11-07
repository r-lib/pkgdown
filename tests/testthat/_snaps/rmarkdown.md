# render_rmarkdown yields useful error

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Output
      Reading 'assets/pandoc-fail.Rmd'
      -- RMarkdown error -------------------------------------------------------------
      [WARNING] Could not fetch resource path-to-image.png
      Failing because there were warnings.
      --------------------------------------------------------------------------------
    Condition
      Error in `render_rmarkdown()`:
      ! Failed to render RMarkdown
      Caused by error:
      ! in callr subprocess.
      Caused by error:
      ! pandoc document conversion failed with error 3

# render_rmarkdown styles ANSI escapes

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

