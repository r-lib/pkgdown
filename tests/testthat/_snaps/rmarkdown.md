# render_rmarkdown copies image files in subdirectories

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
    Message
      Reading assets/vignette-with-img.Rmd
      Writing `test.html`

# render_rmarkdown yields useful error

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Message
      Reading assets/pandoc-fail.Rmd
    Condition
      Error in `render_rmarkdown()`:
      ! Failed to render RMarkdown document.
      x [WARNING] Could not fetch resource path-to-image.png Failing because there were warnings.
      Caused by error:
      ! in callr subprocess.
      Caused by error:
      ! pandoc document conversion failed with error 3

# render_rmarkdown styles ANSI escapes

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")
    Message
      Reading assets/vignette-with-crayon.Rmd
      Writing `test.html`

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

