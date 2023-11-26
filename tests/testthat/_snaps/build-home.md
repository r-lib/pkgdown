# intermediate files cleaned up automatically

    Code
      build_home(pkg)

---

    Code
      build_home(pkg)

# warns about missing images [plain]

    Code
      build_home(pkg)
    Condition
      Warning:
      Missing images in 'README.md': 'foo.png'
      i pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing images [ansi]

    Code
      build_home(pkg)
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mREADME.md[39m: [34mfoo.png[39m
      [36mi[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m

# warns about missing images [unicode]

    Code
      build_home(pkg)
    Condition
      Warning:
      Missing images in 'README.md': 'foo.png'
      ℹ pkgdown can only use images in 'man/figures' and 'vignettes'

# warns about missing images [fancy]

    Code
      build_home(pkg)
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mMissing images in [34mREADME.md[39m: [34mfoo.png[39m
      [36mℹ[39m pkgdown can only use images in [34mman/figures[39m and [34mvignettes[39m

# can build site even if no Authors@R present

    Code
      build_home(pkg)

# .github files are copied and linked

    Code
      build_home(pkg)

