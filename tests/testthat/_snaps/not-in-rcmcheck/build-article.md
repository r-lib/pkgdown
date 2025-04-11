# build_article yields useful error if R fails

    Code
      build_article("test", pkg)
    Message
      Reading vignettes/test.Rmd
    Condition
      Error in `build_article()`:
      ! Failed to render 'vignettes/test.Rmd'.
      x Quitting from test.Rmd:4-9 [unnamed-chunk-1]
      Caused by error:
      ! Error!

