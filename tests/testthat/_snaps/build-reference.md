# parse failures include file name

    Code
      build_reference(pkg)
    Output
      -- Building function reference -------------------------------------------------
      Writing 'reference/index.html'
      Reading 'man/f.Rd'
    Condition
      Error in `purrr::map()`:
      i In index: 1.
      Caused by error in `.f()`:
      ! Failed to parse Rd in f.Rd
      In index: 4.
      Caused by error in `purrr::map()`:
      i In index: 4.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse \url{}.
      i Check for empty \url{} tags.

