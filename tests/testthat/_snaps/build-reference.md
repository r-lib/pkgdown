# parse failures include file name

    Code
      build_reference(pkg)
    Output
      -- Building function reference -------------------------------------------------
      Writing 'reference/index.html'
      Reading 'man/f.Rd'
    Error <rlang_error>
      Failed to parse Rd in f.Rd
        i Failed to parse \url{}.
        i Check for empty \url{} tags.
      Caused by error in `stop_bad_tag()`:
        Failed to parse \url{}.
        i Check for empty \url{} tags.

