# bad inputs give informative warnings

    Code
      t <- select_topics("x + ", topics)
    Condition
      Error:
      ! Topic must be valid R code, not "x + ".
      i Run `usethis::edit_pkgdown_config()` to edit.
    Code
      t <- select_topics("y", topics)
    Condition
      Error:
      ! Topic must be a known topic name or alias, not "y".
      i Run `usethis::edit_pkgdown_config()` to edit.
    Code
      t <- select_topics("paste(1)", topics)
    Condition
      Error:
      ! Failed to evaluate topic selector "paste(1)".
      Caused by error in `paste()`:
      ! could not find function "paste"
    Code
      t <- select_topics("starts_with", topics)
    Condition
      Error:
      ! Topic must be a known topic name or alias, not "starts_with".
      i Run `usethis::edit_pkgdown_config()` to edit.
    Code
      t <- select_topics("1", topics)
    Condition
      Error:
      ! Topic must be a string or function call, not "1".
      i Run `usethis::edit_pkgdown_config()` to edit.
    Code
      t <- select_topics("starts_with('y')", topics, check = TRUE)
    Condition
      Error:
      ! No topics matched in pkgdown config. No topics selected.
      i Run `usethis::edit_pkgdown_config()` to edit.

# selector functions validate their inputs

    Code
      t <- select_topics("starts_with('x', 'y')", topics)
    Condition
      Error:
      ! Failed to evaluate topic selector "starts_with('x', 'y')".
      Caused by error in `starts_with()`:
      ! `internal` must be `TRUE` or `FALSE`, not the string "y".
    Code
      t <- select_topics("starts_with(c('x', 'y'))", topics)
    Condition
      Error:
      ! Failed to evaluate topic selector "starts_with(c('x', 'y'))".
      Caused by error in `starts_with()`:
      ! `x` must be a single string, not a character vector.

# can select by name or alias

    Code
      select_topics("a4", topics)
    Condition
      Error:
      ! Topic must be a known topic name or alias, not "a4".
      i Run `usethis::edit_pkgdown_config()` to edit.
    Code
      select_topics("c::a", topics)
    Condition
      Error:
      ! Topic must be a known topic name or alias, not "c::a".
      i Run `usethis::edit_pkgdown_config()` to edit.

# an unmatched selection generates a warning

    Code
      select_topics(c("a", "starts_with('unmatched')"), topics, check = TRUE)
    Condition
      Error:
      ! Topic must match a function or concept, not "starts_with('unmatched')".
      i Run `usethis::edit_pkgdown_config()` to edit.

