# render_rmarkdown copies image files in subdirectories [plain]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")

# render_rmarkdown copies image files in subdirectories [ansi]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")

# render_rmarkdown copies image files in subdirectories [unicode]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")

# render_rmarkdown copies image files in subdirectories [fancy]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")

# render_rmarkdown yields useful error [plain]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Output
      [WARNING] Could not fetch resource path-to-image.png
      Failing because there were warnings.
    Condition
      Error in `value[[3L]]()`:
      ! Failed to render RMarkdown document

# render_rmarkdown yields useful error [ansi]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Output
      [WARNING] Could not fetch resource path-to-image.png
      Failing because there were warnings.
    Condition
      [1m[33mError[39m in `value[[3L]]()`:[22m
      [1m[22m[33m![39m Failed to render RMarkdown document

# render_rmarkdown yields useful error [unicode]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Output
      [WARNING] Could not fetch resource path-to-image.png
      Failing because there were warnings.
    Condition
      Error in `value[[3L]]()`:
      ! Failed to render RMarkdown document

# render_rmarkdown yields useful error [fancy]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Output
      [WARNING] Could not fetch resource path-to-image.png
      Failing because there were warnings.
    Condition
      [1m[33mError[39m in `value[[3L]]()`:[22m
      [1m[22m[33m![39m Failed to render RMarkdown document

# render_rmarkdown styles ANSI escapes [plain]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

# render_rmarkdown styles ANSI escapes [ansi]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

# render_rmarkdown styles ANSI escapes [unicode]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

# render_rmarkdown styles ANSI escapes [fancy]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

