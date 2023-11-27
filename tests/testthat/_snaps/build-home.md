# intermediate files cleaned up automatically

    Code
      build_home(pkg)
    Message
      Writing authors.html
      Writing 404.html

---

    Code
      build_home(pkg)
    Message
      Writing authors.html
      Writing 404.html

# warns about missing images [plain]

    Code
      build_home(pkg)
    Message
      Writing authors.html
    Condition
      Warning:
      Missing images in 'README.md': 'foo.png'
      i pkgdown can only use images in 'man/figures' and 'vignettes'
    Message
      Writing 404.html

# warns about missing images [ansi]

    Code
      build_home(pkg)
    Message
      [1m[22mWriting [1m[36mauthors.html[39m[22m
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mREADME.md[39m: [34mfoo.png[39m
      [36mi[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m
    Message
      [1m[22mWriting [1m[36m404.html[39m[22m

# warns about missing images [unicode]

    Code
      build_home(pkg)
    Message
      Writing authors.html
    Condition
      Warning:
      Missing images in 'README.md': 'foo.png'
      ℹ pkgdown can only use images in 'man/figures' and 'vignettes'
    Message
      Writing 404.html

# warns about missing images [fancy]

    Code
      build_home(pkg)
    Message
      [1m[22mWriting [1m[36mauthors.html[39m[22m
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mREADME.md[39m: [34mfoo.png[39m
      [36mℹ[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m
    Message
      [1m[22mWriting [1m[36m404.html[39m[22m

# can build site even if no Authors@R present

    Code
      build_home(pkg)
    Message
      Writing authors.html
      Writing 404.html

# .github files are copied and linked

    Code
      build_home(pkg)
    Message
      Writing authors.html
      Reading .github/404.md
      Writing 404.html
      Reading .github/CODE_OF_CONDUCT.md
      Writing CODE_OF_CONDUCT.html
      Reading .github/SUPPORT.md
      Writing SUPPORT.html

