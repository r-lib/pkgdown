# DOIs are linked

    Code
      rd2html("\\doi{test}")
    Output
      [1] "doi: <a href='https://doi.org/test'>test</a>"

# bad specs throw errors

    Code
      rd2html("\\url{}")
    Error <rlang_error>
      Failed to parse \url{}.
      i Check for empty \url{} tags.
    Code
      rd2html("\\url{a\nb}")
    Error <rlang_error>
      Failed to parse \url{}.
      i This may be caused by a \url tag that spans a line break.
    Code
      rd2html("\\email{}")
    Error <simpleError>
      subscript out of bounds
    Code
      rd2html("\\linkS4class{}")
    Error <rlang_error>
      Failed to parse \linkS4class{}.

