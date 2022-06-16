# bad inputs give informative warnings

    Code
      t <- select_topics("x + ", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be valid R code
      x Not 'x + '
    Code
      t <- select_topics("y", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be a known topic name or alias
      x Not 'y'
    Code
      t <- select_topics("paste(1)", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be a known selector function
      x Not 'paste(1)'
      Caused by error in `paste()`:
      ! could not find function "paste"
    Code
      t <- select_topics("starts_with", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be a known topic name or alias
      x Not 'starts_with'
    Code
      t <- select_topics("1", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be a string or function call
      x Not '1'
    Code
      t <- select_topics("starts_with('y')", topics, check = TRUE)
    Condition
      Error in `select_topics()`:
      ! No topics matched in '_pkgdown.yml'. No topics selected.

# can select by name or alias

    Code
      select_topics("a4", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be a known topic name or alias
      x Not 'a4'
    Code
      select_topics("c::a", topics)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must be a known topic name or alias
      x Not 'c::a'

# an unmatched selection generates a warning

    Code
      select_topics(c("a", "starts_with('unmatched')"), topics, check = TRUE)
    Condition
      Error:
      ! In '_pkgdown.yml', topic must match a function or concept
      x Not 'starts_with(\'unmatched\')'

