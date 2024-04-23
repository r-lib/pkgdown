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
      Error:
      ! All topics must be included in reference index
      x Missing topics: c, e, and ?
      i Either add to _pkgdown.yml or use @keywords internal

# errors well when a content entry is empty

    Section "bla": contents 2 is empty.
    i This typically indicates that your _pkgdown.yml is malformed.

# errors well when a content entry is not a character

    Code
      build_reference_index(pkg)
    Condition
      Error in `build_reference_index()`:
      ! Section "bla": 2 must be a character.
      i You might need to add '' around special values like 'N' or 'off'
      i This typically indicates that your _pkgdown.yml is malformed.

# errors well when a content is totally empty

    Code
      build_reference_index(pkg)
    Condition
      Error in `build_reference_index()`:
      ! Section "bla": contents is empty.
      i This typically indicates that your _pkgdown.yml is malformed.

# errors well when a content entry refers to a not installed package

    Code
      build_reference_index(pkg)
    Condition
      Error in `build_reference_index()`:
      ! The package "notapackage" is required as it's used in the reference index.

# errors well when a content entry refers to a non existing function

    Code
      build_reference_index(pkg)
    Condition
      Error in `build_reference_index()`:
      ! Could not find documentation for `rlang::lala()`.

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
        - path: https://rdrr.io/pkg/bslib/man/bs_bundle.html
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
      

# can use a selector name as a topic name

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
        - path: matches.html
          title: matches
          aliases: matches()
          icon: ~
        - path: A.html
          title: A
          aliases: A()
          icon: ~
        names:
        - matches
        - A
        row_has_icons: no
        is_internal: no
      has_icons: no
      

