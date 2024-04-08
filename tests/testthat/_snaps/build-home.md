# intermediate files cleaned up automatically

    Code
      build_home(pkg)
    Message
      Writing `authors.html`
      Writing `404.html`

---

    Code
      build_home(pkg)
    Message
      Writing `authors.html`
      Writing `404.html`

# warns about missing images

    Code
      build_home(pkg)
    Message
      Writing `authors.html`
    Condition
      Warning:
      Missing images in 'README.md': 'foo.png'
      i pkgdown can only use images in 'man/figures' and 'vignettes'
    Message
      Writing `404.html`

# can build site even if no Authors@R present

    Code
      build_home(pkg)
    Message
      Writing `authors.html`
      Writing `404.html`

# .github files are copied and linked

    Code
      build_home(pkg)
    Message
      Writing `authors.html`
      Reading .github/404.md
      Writing `404.html`
      Reading .github/CODE_OF_CONDUCT.md
      Writing `CODE_OF_CONDUCT.html`
      Reading .github/SUPPORT.md
      Writing `SUPPORT.html`

