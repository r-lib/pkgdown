# links to man/figures are automatically relocated

    Code
      copy_figures(pkg)

---

    Code
      build_articles(pkg, lazy = FALSE)

# warns about missing images [plain]

    Code
      build_articles(pkg)
    Condition
      Warning:
      Missing images in 'vignettes/html-vignette.Rmd': 'foo.png'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing images [ansi]

    Code
      build_articles(pkg)
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mvignettes/html-vignette.Rmd[39m: [34mfoo.png[39m
      [36mi[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m

# warns about missing images [unicode]

    Code
      build_articles(pkg)
    Condition
      Warning:
      Missing images in 'vignettes/html-vignette.Rmd': 'foo.png'
      ℹ pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing images [fancy]

    Code
      build_articles(pkg)
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mvignettes/html-vignette.Rmd[39m: [34mfoo.png[39m
      [36mℹ[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m

# articles don't include header-attrs.js script

    Code
      path <- build_article("standard", pkg)

# can build article that uses html_vignette

    Code
      expect_error(build_article("html-vignette", pkg), NA)

# can override html_document() options

    Code
      path <- build_article("html-document", pkg)

# html widgets get needed css/js

    Code
      path <- build_article("widget", pkg)

# can override options with _output.yml

    Code
      path <- build_article("html-document", pkg)

# can set width

    Code
      path <- build_article("width", pkg)

# finds external resources referenced by R code in the article html

    Code
      path <- build_article("resources", pkg)

# BS5 article laid out correctly with and without TOC

    Code
      init_site(pkg)

---

    Code
      toc_true_path <- build_article("standard", pkg)

---

    Code
      toc_false_path <- build_article("toc-false", pkg)

# articles in vignettes/articles/ are unnested into articles/

    Code
      path <- build_article("articles/nested", pkg)

---

    Code
      build_redirects(pkg)

# pkgdown deps are included only once in articles

    Code
      init_site(pkg)

---

    Code
      path <- build_article("html-deps", pkg)

