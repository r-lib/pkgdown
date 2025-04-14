# build_article yields useful error if R fails

    Code
      build_article("test", pkg)
    Message
      Reading vignettes/test.Rmd
    Condition
      Error in `build_article()`:
      ! Failed to render 'vignettes/test.Rmd'.
      x Quitting from test.Rmd:4-10 [unnamed-chunk-1]
      Caused by error:
      ! Error!

---

    Code
      summary(expect_error(build_article("test", pkg)))
    Message
      Reading vignettes/test.Rmd
    Output
      <error/rlang_error>
      Error in `build_article()`:
      ! Failed to render 'vignettes/test.Rmd'.
      x Quitting from test.Rmd:4-10 [unnamed-chunk-1]
      Caused by error:
      ! Error!
      ---
      Backtrace:
          x
       1. \-global f()
       2.   \-global g()
       3.     \-global h()

