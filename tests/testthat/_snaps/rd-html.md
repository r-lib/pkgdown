# subsection generates h3

    Code
      cli::cat_line(rd2html("\\subsection{A}{B}"))
    Output
      <div class='section' id='a'>
      <h3>A</h3>
      <p>B</p>
      </div>

---

    Code
      cli::cat_line(rd2html("\\subsection{A}{\n    p1\n\n    p2\n  }"))
    Output
      <div class='section' id='a'>
      <h3>A</h3>
      <p>p1</p>
      <p>p2</p>
      </div>

# nested subsection generates h4

    Code
      cli::cat_line(rd2html("\\subsection{H3}{\\subsection{H4}{}}"))
    Output
      <div class='section' id='h-'>
      <h3>H3</h3>
      <div class='section' id='h-'>
      <h4>H4</h4>
      
      </div>
      </div>

# Sexprs with multiple args are parsed

    Code
      rd2html("\\Sexpr[results=verbatim]{1}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error in `map_()`:
      ! \\Sexpr{result=verbatim} not yet supported

# bad specs throw errors

    Code
      rd2html("\\url{}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error:
      ! Failed to parse tag "\\url{}".
      i Check for empty \url{} tags.
    Code
      rd2html("\\url{a\nb}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error:
      ! Failed to parse tag "\\url{}".
      i This may be caused by a \url tag that spans a line break.
    Code
      rd2html("\\email{}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error:
      ! Failed to parse tag "\\email{}".
      i empty
    Code
      rd2html("\\linkS4class{}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error:
      ! Failed to parse tag "\\linkS4class{}".

# \describe items can contain multiple paragraphs

    <dl>
    <dt>Label 1</dt>
    <dd><p>Contents 1</p></dd>
    
    <dt>Label 2</dt>
    <dd><p>Contents 2</p></dd>
    
    
    </dl>

---

    <dl>
    <dt>Label</dt>
    <dd><p>Paragraph 1</p>
    <p>Paragraph 2</p></dd>
    
    
    </dl>

# nested item with whitespace parsed correctly

    <dl>
    <dt>Label</dt>
    <dd>
    
    <p>This text is indented in a way pkgdown doesn't like.</p></dd>
    
    </dl>

