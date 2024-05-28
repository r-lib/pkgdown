# check_bslib_theme() works

    Code
      check_bslib_theme("paper", pkg, bs_version = 4)
    Condition
      Error:
      x Can't find Bootswatch/bslib theme preset "paper" (template.bootswatch).
      i Using Bootstrap version 4 (template.bootstrap).
      i Edit _pkgdown.yml to fix the problem.
    Code
      check_bslib_theme("paper", pkg, bs_version = 4, field = c("template", "preset"))
    Condition
      Error:
      x Can't find Bootswatch/bslib theme preset "paper" (template and preset).
      i Using Bootstrap version 4 (template.bootstrap).
      i Edit _pkgdown.yml to fix the problem.

# capture data_template()

    package:
      name: testpackage
      version: 1.0.0
    site:
      root: ''
      title: testpackage
    year: <year>
    lang: en
    translate:
      skip: Skip to contents
      toggle_nav: Toggle navigation
      on_this_page: On this page
      source: Source
      abstract: Abstract
      authors: Authors
      version: Version
      examples: Examples
      citation: Citation
      author_details: Additional details
      toc: Table of contents
      site_nav: Site navigation
    has_favicons: no
    opengraph: []
    extra:
      css: ~
      js: ~
    yaml:
      .present: yes
    development:
      destination: dev
      mode: default
      version_label: default
      in_dev: no
      version_tooltip: ''
    navbar:
      type: default
      left: |-
        <li>
          <a href="reference/index.html">Reference</a>
        </li>
      right: ''
    footer:
      left: <p>Developed by Hadley Wickham, RStudio.</p>
      right: <p>Site built with <a href="https://pkgdown.r-lib.org/">pkgdown</a> {version}.</p>
    lightswitch: no
    

# check_opengraph validates inputs

    Code
      check_open_graph_(list(foo = list()), )
    Condition
      Warning in `check_open_graph_()`:
      '_pkgdown.yml': Unsupported template.opengraph field: "foo".
    Output
      named list()
    Code
      check_open_graph_(list(foo = list(), bar = list()))
    Condition
      Warning in `check_open_graph_()`:
      '_pkgdown.yml': Unsupported template.opengraph fields: "foo" and "bar".
    Output
      named list()
    Code
      check_open_graph_(list(twitter = 1))
    Condition
      Error in `check_open_graph_()`:
      ! '_pkgdown.yml': template.opengraph.twitter must be a list, not the number 1.
    Code
      check_open_graph_(list(twitter = list()))
    Condition
      Error in `check_open_graph_()`:
      ! '_pkgdown.yml': opengraph.twitter must include either creator or site.
    Code
      check_open_graph_(list(image = 1))
    Condition
      Error in `check_open_graph_()`:
      ! '_pkgdown.yml': template.opengraph.image must be a list, not the number 1.

