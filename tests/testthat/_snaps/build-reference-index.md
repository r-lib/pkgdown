# can generate three types of row

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Function reference
      rows:
      - title: A
        slug: a
        desc: ~
        is_internal: no
      - subtitle: B
        slug: b
        desc: ~
        is_internal: no
      - topics:
        - path: a.html
          title: A
          aliases: a()
          icon: ~
        - path: b.html
          title: B
          aliases: b()
          icon: ~
        - path: c.html
          title: C
          aliases: c()
          icon: ~
        - path: e.html
          title: E
          aliases: e
          icon: ~
        - path: help.html
          title: D
          aliases: '`?`()'
          icon: ~
        names:
        - a
        - b
        - c
        - e
        - '?'
        row_has_icons: no
        is_internal: no
      has_icons: no
      

# warns if missing topics

    Code
      data_reference_index(pkg)
    Condition
      Error in `check_missing_topics()`:
      ! All topics must be included in reference index
      x Missing topics: c, e, ?
      i Either add to _pkgdown.yml or use @keyword internal

# errors well when a content entry is empty

    Item 2 in section 1 in reference in '_pkgdown.yml' is empty.
    i Either delete the empty line or add a function name.

# errors well when a content entry is not a character

    Item 2 in section 1 in reference in '_pkgdown.yml' must be a character.
    i You might need to add '' around e.g. - 'N' or - 'off'.

# errors well when a content entry refers to a not installed package

    The package `notapackage` is required as it's used in the reference index.

# errors well when a content entry refers to a non existing function

    Could not find documentation for rlang::lala

# can use a topic from another package

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Function reference
      rows:
      - title: bla
        slug: bla
        desc: ~
        is_internal: no
      - topics:
        - path: a.html
          title: A
          aliases: a()
          icon: ~
        - path: b.html
          title: B
          aliases: b()
          icon: ~
        - path: c.html
          title: C
          aliases: c()
          icon: ~
        - path: e.html
          title: E
          aliases: e
          icon: ~
        - path: help.html
          title: D
          aliases: '`?`()'
          icon: ~
        - path: https://rlang.r-lib.org/reference/is_installed.html
          title: Are packages installed in any of the libraries? (from rlang)
          aliases:
          - is_installed()
          - check_installed()
          icon: ~
        - path: https://rstudio.github.io/bslib/reference/bs_bundle.html
          title: Add low-level theming customizations (from bslib)
          aliases:
          - bs_add_variables()
          - bs_add_rules()
          - bs_add_functions()
          - bs_add_mixins()
          - bs_bundle()
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
        is_internal: no
      has_icons: no
      

