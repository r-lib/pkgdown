# can generate three types of row

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Function reference
      rows:
      - title: A
        slug: a
        desc: ~
      - subtitle: B
        slug: b
        desc: ~
      - topics:
        - path: a.html
          aliases: a()
          title: A
          icon: ~
        - path: b.html
          aliases: b()
          title: B
          icon: ~
        - path: c.html
          aliases: c()
          title: C
          icon: ~
        - path: e.html
          aliases: e
          title: E
          icon: ~
        - path: help.html
          aliases: '`?`()'
          title: D
          icon: ~
        names:
        - a
        - b
        - c
        - e
        - '?'
        row_has_icons: no
      has_icons: no
      

# errors well when a content entry is not a character

    Item 1 in section 1 in reference in '_pkgdown.yml' must be a character.
    i You might need to add '' around e.g. - 'N' or - 'off'.

# errors well when a content entry refers to a not installed package

    The package `notapackage` is required as it is mentioned in the reference index.

# errors well when a content entry refers to a non existing function

    Could not find an href for topic lala of package rlang

# can use a topic from another package

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Function reference
      rows:
      - title: bla
        slug: bla
        desc: ~
      - topics:
        - path: a.html
          aliases: a()
          title: A
          icon: ~
        - path: b.html
          aliases: b()
          title: B
          icon: ~
        - path: c.html
          aliases: c()
          title: C
          icon: ~
        - path: e.html
          aliases: e
          title: E
          icon: ~
        - path: help.html
          aliases: '`?`()'
          title: D
          icon: ~
        - path: https://rlang.r-lib.org/reference/is_installed.html
          aliases:
          - is_installed()
          - check_installed()
          title: Are packages installed in any of the libraries? (from rlang)
          icon: ~
        - path: https://rstudio.github.io/bslib/reference/bs_bundle.html
          aliases:
          - bs_add_variables()
          - bs_add_rules()
          - bs_add_functions()
          - bs_add_mixins()
          - bs_bundle()
          title: Add low-level theming customizations (from bslib)
          icon: ~
        names:
        - a
        - b
        - c
        - e
        - '?'
        - rlang::is_installed()
        - bslib::bs_add_rules
        row_has_icons: no
      has_icons: no
      

