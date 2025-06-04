# build_site can be made unquiet

    Code
      build_site(pkg, quiet = FALSE)
    Message
      -- Installing package kittens into temporary library ---------------------------
    Output
      ── Building pkgdown site for package kittens ───────────────────────────────────
      Reading from:
      <src_path>
      Writing to:
      <dst_path>
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
      
      
      processing file: kitten.Rmd
      1/10                  
      2/10 [unnamed-chunk-1]
      3/10                  
      4/10 [unnamed-chunk-2]
      5/10                  
      6/10 [unnamed-chunk-3]
      7/10                  
      8/10 [magick]         
      9/10                  
      10/10 [plot]           
      output file: /private/var/folders/7m/55bk34v53x12cjztb1fwxgvw0000gn/T/Rtmp7sGn6Y/kitten.knit.md
      
      /opt/homebrew/bin/pandoc +RTS -K512m -RTS /private/var/folders/7m/55bk34v53x12cjztb1fwxgvw0000gn/T/Rtmp7sGn6Y/kitten.knit.md --to html4 --from markdown+autolink_bare_uris+tex_math_single_backslash --output <dst_path>/articles/kitten.html --lua-filter /Users/jayhesselberth/Library/R/arm64/4.5/library/rmarkdown/rmarkdown/lua/pagebreak.lua --lua-filter /Users/jayhesselberth/Library/R/arm64/4.5/library/rmarkdown/rmarkdown/lua/latex-div.lua --lua-filter /Users/jayhesselberth/Library/R/arm64/4.5/library/rmarkdown/rmarkdown/lua/table-classes.lua --standalone --section-divs --template /var/folders/7m/55bk34v53x12cjztb1fwxgvw0000gn/T//Rtmp7sGn6Y/pkgdown-rmd-template-11ef728bef6ba.html --highlight-style pygments --mathml --include-in-header /var/folders/7m/55bk34v53x12cjztb1fwxgvw0000gn/T//RtmpPvBjXL/rmarkdown-str11fc0c439f75.html 
      
      Output created: <dst_path>/articles/kitten.html
      Warning messages:
      1: 'mode(bg)' differs between new and previous
      	 ==> NOT changing 'bg' 
      2: 'mode(bg)' differs between new and previous
      	 ==> NOT changing 'bg' 
      3: 'mode(bg)' differs between new and previous
      	 ==> NOT changing 'bg' 
      4: 'mode(bg)' differs between new and previous
      	 ==> NOT changing 'bg' 
      5: 'mode(bg)' differs between new and previous
      	 ==> NOT changing 'bg' 
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

