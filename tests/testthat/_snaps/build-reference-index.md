# can generate three types of row

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Package index
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
      ! 3 topics missing from index: "c", "e", and "?".
      i Either use `@keywords internal` to drop from index, or
      i Edit _pkgdown.yml to fix the problem.

# gives informative errors

    Code
      data_reference_index_(1)
    Condition
      Error in `config_pluck_reference()`:
      ! reference must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(1))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1] must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(title = 1)))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1].title must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(subtitle = 1)))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1].subtitle must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(title = "bla", contents = 1)))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1].contents[1] must be a string.
      i You might need to add '' around special YAML values like 'N' or 'off'
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(title = "bla", contents = NULL)))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1].contents is empty.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(title = "bla", contents = list("a", NULL))))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1].contents[2] is empty.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(title = "bla", contents = list())))
    Condition
      Error in `data_reference_index_()`:
      ! reference[1].contents is empty.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_reference_index_(list(list(title = "bla", contents = "notapackage::lala")))
    Condition
      Error in `build_reference_index()`:
      ! The package "notapackage" is required as it's used in the reference index.
    Code
      data_reference_index_(list(list(title = "bla", contents = "rlang::lala")))
    Condition
      Error in `build_reference_index()`:
      ! Could not find documentation for `rlang::lala()`.

# can use a topic from another package

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Package index
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
      pagetitle: Package index
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
      

