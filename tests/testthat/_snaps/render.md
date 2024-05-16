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

# check_opengraph validates inputs

    Code
      check_open_graph_(list(foo = list()), )
    Condition
      Warning in `check_open_graph_()`:
      '_pkgdown.yml': Unsupported `template.opengraph` field: "foo".
    Output
      named list()
    Code
      check_open_graph_(list(foo = list(), bar = list()))
    Condition
      Warning in `check_open_graph_()`:
      '_pkgdown.yml': Unsupported `template.opengraph` fields: "foo" and "bar".
    Output
      named list()
    Code
      check_open_graph_(list(twitter = 1))
    Condition
      Error in `check_open_graph_()`:
      ! '_pkgdown.yml': `template.opengraph.twitter` must be a list, not a double vector.
    Code
      check_open_graph_(list(twitter = list()))
    Condition
      Error in `check_open_graph_()`:
      ! `opengraph.twitter` must include either `creator` or `site`.
    Code
      check_open_graph_(list(image = 1))
    Condition
      Error in `check_open_graph_()`:
      ! '_pkgdown.yml': `template.opengraph.image` must be a list, not a double vector.

