# links to man/figures are automatically relocated

    Code
      copy_figures(pkg)
    Message
      Copying man/figures/kitten.jpg
      to reference/figures/kitten.jpg

---

    Code
      build_articles(pkg, lazy = FALSE)
    Message
      Writing articles/index.html
      Reading vignettes/kitten.Rmd
      Writing articles/kitten.html

# warns about missing images [plain]

    Code
      build_articles(pkg)
    Message
      Writing articles/index.html
      Reading vignettes/html-vignette.Rmd
      Writing articles/html-vignette.html
    Condition
      Warning:
      Missing images in 'vignettes/html-vignette.Rmd': 'foo.png'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing images [ansi]

    Code
      build_articles(pkg)
    Message
      [1m[22mWriting [1m[36marticles/index.html[39m[22m
      [1m[22mReading [1m[32mvignettes/html-vignette.Rmd[39m[22m
      [1m[22mWriting [1m[36marticles/html-vignette.html[39m[22m
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mvignettes/html-vignette.Rmd[39m: [34mfoo.png[39m
      [36mi[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m

# warns about missing images [unicode]

    Code
      build_articles(pkg)
    Message
      Writing articles/index.html
      Reading vignettes/html-vignette.Rmd
      Writing articles/html-vignette.html
    Condition
      Warning:
      Missing images in 'vignettes/html-vignette.Rmd': 'foo.png'
      ℹ pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing images [fancy]

    Code
      build_articles(pkg)
    Message
      [1m[22mWriting [1m[36marticles/index.html[39m[22m
      [1m[22mReading [1m[32mvignettes/html-vignette.Rmd[39m[22m
      [1m[22mWriting [1m[36marticles/html-vignette.html[39m[22m
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mvignettes/html-vignette.Rmd[39m: [34mfoo.png[39m
      [36mℹ[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m

# articles don't include header-attrs.js script

    Code
      path <- build_article("standard", pkg)
    Message
      Reading vignettes/standard.Rmd
      Writing articles/standard.html

# can build article that uses html_vignette

    Code
      expect_error(build_article("html-vignette", pkg), NA)
    Message
      Reading vignettes/html-vignette.Rmd
      Writing articles/html-vignette.html

# can override html_document() options

    Code
      path <- build_article("html-document", pkg)
    Message
      Reading vignettes/html-document.Rmd
      Writing articles/html-document.html

# html widgets get needed css/js

    Code
      path <- build_article("widget", pkg)
    Message
      Reading vignettes/widget.Rmd
      Writing articles/widget.html

# can override options with _output.yml

    Code
      path <- build_article("html-document", pkg)
    Message
      Reading vignettes/html-document.Rmd
      Writing articles/html-document.html

# can set width

    Code
      path <- build_article("width", pkg)
    Message
      Reading vignettes/width.Rmd
      Writing articles/width.html

# finds external resources referenced by R code in the article html

    Code
      path <- build_article("resources", pkg)
    Message
      Reading vignettes/resources.Rmd
      Writing articles/resources.html

# BS5 article laid out correctly with and without TOC

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      toc_true_path <- build_article("standard", pkg)
    Message
      Reading vignettes/standard.Rmd
      Writing articles/standard.html

---

    Code
      toc_false_path <- build_article("toc-false", pkg)
    Message
      Reading vignettes/toc-false.Rmd
      Writing articles/toc-false.html

# articles in vignettes/articles/ are unnested into articles/

    Code
      path <- build_article("articles/nested", pkg)
    Message
      Reading vignettes/articles/nested.Rmd
      Writing articles/nested.html

---

    Code
      build_redirects(pkg)

# pkgdown deps are included only once in articles

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      path <- build_article("html-deps", pkg)
    Message
      Reading vignettes/html-deps.Rmd
      Writing articles/html-deps.html

