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
    Condition
      Error in `value[[3L]]()`:
      ! Failed to render RMarkdown document
      x pandoc document conversion failed with error 3
      x [WARNING] Could not fetch resource path-to-image.png Failing because there were warnings.

# render_rmarkdown yields useful error [ansi]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Condition
      [1m[33mError[39m in `value[[3L]]()`:[22m
      [1m[22m[33m![39m Failed to render RMarkdown document
      [31mx[39m pandoc document conversion failed with error 3
      [31mx[39m [WARNING] Could not fetch resource path-to-image.png Failing because there were warnings.

# render_rmarkdown yields useful error [unicode]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Condition
      Error in `value[[3L]]()`:
      ! Failed to render RMarkdown document
      ✖ pandoc document conversion failed with error 3
      ✖ [WARNING] Could not fetch resource path-to-image.png Failing because there were warnings.

# render_rmarkdown yields useful error [fancy]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Condition
      [1m[33mError[39m in `value[[3L]]()`:[22m
      [1m[22m[33m![39m Failed to render RMarkdown document
      [31m✖[39m pandoc document conversion failed with error 3
      [31m✖[39m [WARNING] Could not fetch resource path-to-image.png Failing because there were warnings.

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

