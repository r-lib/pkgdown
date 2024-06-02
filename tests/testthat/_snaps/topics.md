# bad inputs give informative warnings

    Code
      select_topics_("x + ", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (x + ) must be valid R code.
    Code
      select_topics_("y", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (y) must be a known topic name or alias.
    Code
      select_topics_("paste(1)", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (paste(1)) failed to evaluate.
      Caused by error in `paste()`:
      ! could not find function "paste"
    Code
      select_topics_("starts_with", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (starts_with) must be a known topic name or alias.
    Code
      select_topics_("1", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (1) must be a string or function call.
    Code
      select_topics_("starts_with('y')", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents failed to match any topics.

# selector functions validate their inputs

    Code
      select_topics_("starts_with('x', 'y')", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (starts_with('x', 'y')) failed to evaluate.
      Caused by error in `starts_with()`:
      ! `internal` must be `TRUE` or `FALSE`, not the string "y".
    Code
      select_topics_("starts_with(c('x', 'y'))", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (starts_with(c('x', 'y'))) failed to evaluate.
      Caused by error in `starts_with()`:
      ! `x` must be a single string, not a character vector.

# can select by name or alias

    Code
      select_topics_("a4", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (a4) must be a known topic name or alias.
    Code
      select_topics_("c::a", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (c::a) must be a known topic name or alias.

# can combine positive and negative selections

    Code
      select_topics_("c(a, -x)", topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents[1] (c(a, -x)) must be all negative or all positive.

# an unmatched selection generates a warning

    Code
      select_topics_(c("a", "starts_with('unmatched')"), topics)
    Condition
      Error in `select_topics_()`:
      ! In _pkgdown.yml, reference[1].contents (starts_with('unmatched')) must match a function or concept.

