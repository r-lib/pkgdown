# render_rmarkdown copies image files in subdirectories [plain]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
    Message
      Reading assets/vignette-with-img.Rmd
      Writing test.html

# render_rmarkdown copies image files in subdirectories [ansi]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
    Message
      [1m[22mReading [1m[32massets/vignette-with-img.Rmd[39m[22m
      [1m[22mWriting [1m[36mtest.html[39m[22m

# render_rmarkdown copies image files in subdirectories [unicode]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
    Message
      Reading assets/vignette-with-img.Rmd
      Writing test.html

# render_rmarkdown copies image files in subdirectories [fancy]

    Code
      render_rmarkdown(pkg, "assets/vignette-with-img.Rmd", "test.html")
    Message
      [1m[22mReading [1m[32massets/vignette-with-img.Rmd[39m[22m
      [1m[22mWriting [1m[36mtest.html[39m[22m

# render_rmarkdown yields useful error [plain]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Message
      Reading assets/pandoc-fail.Rmd
    Condition
      Error in `render_rmarkdown()`:
      ! Failed to render RMarkdown document
      Caused by error:
      ! in callr subprocess.
      Caused by error:
      ! pandoc document conversion failed with error 3

# render_rmarkdown yields useful error [ansi]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Message
      [1m[22mReading [1m[32massets/pandoc-fail.Rmd[39m[22m
    Condition
      [1m[33mError[39m in `render_rmarkdown()`:[22m
      [1m[22m[33m![39m Failed to render RMarkdown document
      [1mCaused by error:[22m
      [33m![39m in callr subprocess.
      [1mCaused by error:[22m
      [33m![39m pandoc document conversion failed with error 3

# render_rmarkdown yields useful error [unicode]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Message
      Reading assets/pandoc-fail.Rmd
    Condition
      Error in `render_rmarkdown()`:
      ! Failed to render RMarkdown document
      Caused by error:
      ! in callr subprocess.
      Caused by error:
      ! pandoc document conversion failed with error 3

# render_rmarkdown yields useful error [fancy]

    Code
      render_rmarkdown(pkg, "assets/pandoc-fail.Rmd", "test.html", output_format = rmarkdown::html_document(
        pandoc_args = "--fail-if-warnings"))
    Message
      [1m[22mReading [1m[32massets/pandoc-fail.Rmd[39m[22m
    Condition
      [1m[33mError[39m in `render_rmarkdown()`:[22m
      [1m[22m[33m![39m Failed to render RMarkdown document
      [1mCaused by error:[22m
      [33m![39m in callr subprocess.
      [1mCaused by error:[22m
      [33m![39m pandoc document conversion failed with error 3

# render_rmarkdown styles ANSI escapes [plain]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")
    Message
      Reading assets/vignette-with-crayon.Rmd
      Writing test.html

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

# render_rmarkdown styles ANSI escapes [ansi]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")
    Message
      [1m[22mReading [1m[32massets/vignette-with-crayon.Rmd[39m[22m
      [1m[22mWriting [1m[36mtest.html[39m[22m

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

# render_rmarkdown styles ANSI escapes [unicode]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")
    Message
      Reading assets/vignette-with-crayon.Rmd
      Writing test.html

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

# render_rmarkdown styles ANSI escapes [fancy]

    Code
      path <- render_rmarkdown(pkg, input = "assets/vignette-with-crayon.Rmd",
        output = "test.html")
    Message
      [1m[22mReading [1m[32massets/vignette-with-crayon.Rmd[39m[22m
      [1m[22mWriting [1m[36mtest.html[39m[22m

---

    <span class="co">#&gt; <span style="color: #BB0000;">X</span></span>

