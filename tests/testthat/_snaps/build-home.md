# warns about missing images

    Code
      build_home(pkg)
    Output
      -- Building home ---------------------------------------------------------------
      Writing 'authors.html'
    Condition
      Warning:
      Missing images in 'README.md': 'foo.png'
      i pkgdown can only use images in 'man/figures' and 'vignettes'
    Output
      Writing '404.html'

# Does not error with math in README.md

    Code
      build_home(pkg)
    Output
      -- Building home ---------------------------------------------------------------
      Writing 'authors.html'
      Writing '404.html'

