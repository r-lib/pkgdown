# extra.css and extra.js copied and linked

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS3/assets/bootstrap-toc.css, ../../../../inst/BS3/assets/bootstrap-toc.js, ../../../../inst/BS3/assets/docsearch.css, ../../../../inst/BS3/assets/docsearch.js, ../../../../inst/BS3/assets/link.svg, ../../../../inst/BS3/assets/pkgdown.css, and ../../../../inst/BS3/assets/pkgdown.js
      to bootstrap-toc.css, bootstrap-toc.js, docsearch.css, docsearch.js, link.svg, pkgdown.css, and pkgdown.js
      Copying pkgdown/extra.css and pkgdown/extra.js
      to extra.css and extra.js

---

    Code
      build_home(pkg)
    Message
      Writing authors.html
      Writing 404.html

# single extra.css correctly copied

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS3/assets/bootstrap-toc.css, ../../../../inst/BS3/assets/bootstrap-toc.js, ../../../../inst/BS3/assets/docsearch.css, ../../../../inst/BS3/assets/docsearch.js, ../../../../inst/BS3/assets/link.svg, ../../../../inst/BS3/assets/pkgdown.css, and ../../../../inst/BS3/assets/pkgdown.js
      to bootstrap-toc.css, bootstrap-toc.js, docsearch.css, docsearch.js, link.svg, pkgdown.css, and pkgdown.js
      Copying pkgdown/extra.css
      to extra.css

# asset subdirectories are copied

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS3/assets/bootstrap-toc.css, ../../../../inst/BS3/assets/bootstrap-toc.js, ../../../../inst/BS3/assets/docsearch.css, ../../../../inst/BS3/assets/docsearch.js, ../../../../inst/BS3/assets/link.svg, ../../../../inst/BS3/assets/pkgdown.css, and ../../../../inst/BS3/assets/pkgdown.js
      to bootstrap-toc.css, bootstrap-toc.js, docsearch.css, docsearch.js, link.svg, pkgdown.css, and pkgdown.js
      Copying pkgdown/assets/subdir1/file1.txt and pkgdown/assets/subdir1/subdir2/file2.txt
      to subdir1/file1.txt and subdir1/subdir2/file2.txt

# site meta doesn't break unexpectedly

    Code
      yaml
    Output
      pandoc: '{version}'
      pkgdown: '{version}'
      pkgdown_sha: '{sha}'
      articles: {}
      last_built: 2020-01-01T00:00Z
      urls:
        reference: http://test.org/reference
        article: http://test.org/articles
      

