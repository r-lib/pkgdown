# can generate three types of row

    Code
      data_reference_index(pkg)
    Output
      pagetitle: Function reference
      rows:
      - title: A
        slug: section-a
        desc: ~
      - subtitle: B
        slug: section-b
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
        - path: help.html
          aliases: '`?`()'
          title: D
          icon: ~
        names:
        - a
        - b
        - c
        - '?'
        row_has_icons: no
      has_icons: no
      

# errors well when a content entry is not a character

    Content 1 in section 1 in reference in '_pkgdown.yml' must be a character.
    i You might need to add '' around e.g. - 'N' or - 'off'.

# errors well when a content entry refers to a not installed package

    notapackage must be installed if it is mentioned in the reference index.

# errors well when a content entry refers to a non existing function

    Could not find an href for topic lala of package usethis

