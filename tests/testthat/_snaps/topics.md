# bad inputs give informative warnings

    Code
      t <- select_topics("x + ", topics)
    Warning <rlang_warning>
      In '_pkgdown.yml', topic must be valid R code
      x Not 'x + '
    Code
      t <- select_topics("y", topics)
    Warning <rlang_warning>
      In '_pkgdown.yml', topic must be a known topic name or alias
      x Not 'y'
    Code
      t <- select_topics("paste(1)", topics)
    Warning <rlang_warning>
      In '_pkgdown.yml', topic must be a known selector function
      x Not 'paste(1)'
    Code
      t <- select_topics("starts_with", topics)
    Warning <rlang_warning>
      In '_pkgdown.yml', topic must be a known topic name or alias
      x Not 'starts_with'
    Code
      t <- select_topics("1", topics)
    Warning <rlang_warning>
      In '_pkgdown.yml', topic must be a string or function call
      x Not '1'
    Code
      t <- select_topics("starts_with('y')", topics, check = TRUE)
    Warning <rlang_warning>
      No topics matched in '_pkgdown.yml'. No topics selected.

