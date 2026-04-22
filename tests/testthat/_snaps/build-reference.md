# parse failures include file name

    Code
      build_reference(pkg)
    Message
      -- Building function reference -------------------------------------------------
      Writing `reference/index.html`
      Reading man/f.Rd
    Condition
      Error in `build_reference()`:
      ! Failed to parse Rd in 'f.Rd'
      Caused by error:
      ! Failed to parse tag "\\url{}".
      i Check for empty \url{} tags.

# examples are reproducible by default, i.e. 'seed' is respected

    Code
      cat(examples)
    Output
      #> [1] 0.080750138 0.834333037 0.600760886 0.157208442 0.007399441

