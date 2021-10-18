# subsection generates h3

    Code
      cat_line(rd2html("\\subsection{A}{B}"))
    Output
      <div id='a'>
      <h3>A</h3>
      <p>B</p>
      </div>

---

    Code
      cat_line(rd2html("\\subsection{A}{\n    p1\n\n    p2\n  }"))
    Output
      <div id='a'>
      <h3>A</h3>
      <p>p1</p>
      <p>p2</p>
      </div>

# nested subsection generates h4

    Code
      cat_line(rd2html("\\subsection{H3}{\\subsection{H4}{}}"))
    Output
      <div id='h-'>
      <h3>H3</h3>
      <div id='h-'>
      <h4>H4</h4>
      
      </div>
      </div>

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

