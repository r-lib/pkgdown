# build_site can be made unquiet

    Code
      build_site(pkg, quiet = FALSE)
    Message
      -- Installing package kittens into temporary library ---------------------------
    Output
      ── Building pkgdown site for package kittens ───────────────────────────────────
      Reading from:
      /Users/jayhesselberth/devel/r-lib/pkgdown/tests/testthat/assets/articles-images
      Writing to:
      /private/var/folders/qx/41mvgp5538j5xcpj3qndhg6m0000gn/T/RtmpOsp2lA/pkgdown-dst478f6b47dba8
      ── Sitrep ──────────────────────────────────────────────────────────────────────
      ✖ URLs not ok.
        In _pkgdown.yml, url is missing.
        See details in `vignette(pkgdown::metadata)`.
      ✔ Favicons ok.
      ✔ Open graph metadata ok.
      ✔ Articles metadata ok.
      ✔ Reference metadata ok.
      ── Initialising site ───────────────────────────────────────────────────────────
      Copying <pkgdown>/BS5/assets/katex-auto.js to katex-auto.js
      Copying <pkgdown>/BS5/assets/lightswitch.js to lightswitch.js
      Copying <pkgdown>/BS5/assets/link.svg to link.svg
      Copying <pkgdown>/BS5/assets/pkgdown.js to pkgdown.js
      Updating deps/bootstrap-5.3.1/bootstrap.bundle.min.js
      Updating deps/bootstrap-5.3.1/bootstrap.bundle.min.js.map
      Updating deps/bootstrap-5.3.1/bootstrap.min.css
      Updating deps/bootstrap-toc-1.0.1/bootstrap-toc.min.js
      Updating deps/clipboard.js-2.0.11/clipboard.min.js
      Updating deps/font-awesome-6.5.2/css/all.css
      Updating deps/font-awesome-6.5.2/css/all.min.css
      Updating deps/font-awesome-6.5.2/css/v4-shims.css
      Updating deps/font-awesome-6.5.2/css/v4-shims.min.css
      Updating deps/font-awesome-6.5.2/webfonts/fa-brands-400.ttf
      Updating deps/font-awesome-6.5.2/webfonts/fa-brands-400.woff2
      Updating deps/font-awesome-6.5.2/webfonts/fa-regular-400.ttf
      Updating deps/font-awesome-6.5.2/webfonts/fa-regular-400.woff2
      Updating deps/font-awesome-6.5.2/webfonts/fa-solid-900.ttf
      Updating deps/font-awesome-6.5.2/webfonts/fa-solid-900.woff2
      Updating deps/font-awesome-6.5.2/webfonts/fa-v4compatibility.ttf
      Updating deps/font-awesome-6.5.2/webfonts/fa-v4compatibility.woff2
      Updating deps/headroom-0.11.0/headroom.min.js
      Updating deps/headroom-0.11.0/jQuery.headroom.min.js
      Updating deps/jquery-3.6.0/jquery-3.6.0.js
      Updating deps/jquery-3.6.0/jquery-3.6.0.min.js
      Updating deps/jquery-3.6.0/jquery-3.6.0.min.map
      Updating deps/search-1.0.0/autocomplete.jquery.min.js
      Updating deps/search-1.0.0/fuse.min.js
      Updating deps/search-1.0.0/mark.min.js
      ── Building home ───────────────────────────────────────────────────────────────
      Writing `authors.html`
      Reading README.md
      Writing `index.html`
      Writing `404.html`
      ── Building function reference ─────────────────────────────────────────────────
      Writing `reference/index.html`
      Copying man/figures/kitten.jpg to reference/figures/kitten.jpg
      Reading man/kitten.Rd
      Writing `reference/kitten.html`
      ── Building articles ───────────────────────────────────────────────────────────
      Writing `articles/index.html`
      Reading vignettes/kitten.Rmd
      Writing `articles/kitten.html`
      ✖ Missing alt-text in 'vignettes/kitten.Rmd'
      • ../reference/figures/kitten.jpg
      • another-kitten.jpg
      • ../reference/figures/kitten.jpg
      • another-kitten.jpg
      • kitten_files/figure-html/magick-1.png
      • kitten_files/figure-html/plot-1.jpg
      ℹ Learn more in `vignette(pkgdown::accessibility)`.
      ── Building sitemap ────────────────────────────────────────────────────────────
      Writing `sitemap.xml`
      ── Building search index ───────────────────────────────────────────────────────
      ── Checking for problems ───────────────────────────────────────────────────────
      ✖ Missing alt-text in 'README.md'
      • reference/figures/kitten.jpg
      ℹ Learn more in `vignette(pkgdown::accessibility)`.
      ── Finished building pkgdown site for package kittens ──────────────────────────
    Message
      -- Finished building pkgdown site for package kittens --------------------------

