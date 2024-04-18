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

# .Rd without usage doesn't get Usage section

    Code
      build_reference(pkg, topics = "e")
    Message
      -- Building function reference -------------------------------------------------
      Writing `reference/index.html`
      Reading man/e.Rd
      Writing `reference/e.html`

---

    Code
      build_reference(pkg, topics = "e")
    Message
      -- Building function reference -------------------------------------------------
      Writing `reference/index.html`
      Reading man/e.Rd
      Writing `reference/e.html`

# pkgdown html dependencies are suppressed from examples in references

    Code
      build_reference(pkg, topics = "a")
    Message
      -- Building function reference -------------------------------------------------
      Writing `reference/index.html`
      Reading man/a.Rd
      Writing `reference/a.html`

# examples are reproducible by default, i.e. 'seed' is respected

    Code
      cat(examples)
    Output
      testpackage:::f()
      #> [1] 0.080750138 0.834333037 0.600760886 0.157208442 0.007399441

