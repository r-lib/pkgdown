# subsection generates h3 [plain]

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

# subsection generates h3 [ansi]

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

# subsection generates h3 [unicode]

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

# subsection generates h3 [fancy]

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

# nested subsection generates h4 [plain]

    Code
      cli::cat_line(rd2html("\\subsection{H3}{\\subsection{H4}{}}"))
    Output
      <div class='section' id='h-'>
      <h3>H3</h3>
      <div class='section' id='h-'>
      <h4>H4</h4>
      
      </div>
      </div>

# nested subsection generates h4 [ansi]

    Code
      cli::cat_line(rd2html("\\subsection{H3}{\\subsection{H4}{}}"))
    Output
      <div class='section' id='h-'>
      <h3>H3</h3>
      <div class='section' id='h-'>
      <h4>H4</h4>
      
      </div>
      </div>

# nested subsection generates h4 [unicode]

    Code
      cli::cat_line(rd2html("\\subsection{H3}{\\subsection{H4}{}}"))
    Output
      <div class='section' id='h-'>
      <h3>H3</h3>
      <div class='section' id='h-'>
      <h4>H4</h4>
      
      </div>
      </div>

# nested subsection generates h4 [fancy]

    Code
      cli::cat_line(rd2html("\\subsection{H3}{\\subsection{H4}{}}"))
    Output
      <div class='section' id='h-'>
      <h3>H3</h3>
      <div class='section' id='h-'>
      <h4>H4</h4>
      
      </div>
      </div>

# Sexprs with multiple args are parsed [plain]

    Code
      rd2html("\\Sexpr[results=verbatim]{1}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error in `.f()`:
      ! \\Sexpr{result=verbatim} not yet supported

# Sexprs with multiple args are parsed [ansi]

    Code
      rd2html("\\Sexpr[results=verbatim]{1}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [1mCaused by error in `.f()`:[22m
      [1m[22m[33m![39m \\Sexpr{result=verbatim} not yet supported

# Sexprs with multiple args are parsed [unicode]

    Code
      rd2html("\\Sexpr[results=verbatim]{1}")
    Condition
      Error in `purrr::map_chr()`:
      ℹ In index: 1.
      Caused by error in `.f()`:
      ! \\Sexpr{result=verbatim} not yet supported

# Sexprs with multiple args are parsed [fancy]

    Code
      rd2html("\\Sexpr[results=verbatim]{1}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [1mCaused by error in `.f()`:[22m
      [1m[22m[33m![39m \\Sexpr{result=verbatim} not yet supported

# bad specs throw errors [plain]

    Code
      rd2html("\\url{}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\url{}`.
      x Check for empty \url{} tags.
    Code
      rd2html("\\url{a\nb}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\url{}`.
      x This may be caused by a \url tag that spans a line break.
    Code
      rd2html("\\email{}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\email{}`.
      x empty
    Code
      rd2html("\\linkS4class{}")
    Condition
      Error in `purrr::map_chr()`:
      i In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\linkS4class{}`.

# bad specs throw errors [ansi]

    Code
      rd2html("\\url{}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\url{}`.
      [31mx[39m Check for empty \url{} tags.
    Code
      rd2html("\\url{a\nb}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\url{}`.
      [31mx[39m This may be caused by a \url tag that spans a line break.
    Code
      rd2html("\\email{}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\email{}`.
      [31mx[39m empty
    Code
      rd2html("\\linkS4class{}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\linkS4class{}`.

# bad specs throw errors [unicode]

    Code
      rd2html("\\url{}")
    Condition
      Error in `purrr::map_chr()`:
      ℹ In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\url{}`.
      ✖ Check for empty \url{} tags.
    Code
      rd2html("\\url{a\nb}")
    Condition
      Error in `purrr::map_chr()`:
      ℹ In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\url{}`.
      ✖ This may be caused by a \url tag that spans a line break.
    Code
      rd2html("\\email{}")
    Condition
      Error in `purrr::map_chr()`:
      ℹ In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\email{}`.
      ✖ empty
    Code
      rd2html("\\linkS4class{}")
    Condition
      Error in `purrr::map_chr()`:
      ℹ In index: 1.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\linkS4class{}`.

# bad specs throw errors [fancy]

    Code
      rd2html("\\url{}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\url{}`.
      [31m✖[39m Check for empty \url{} tags.
    Code
      rd2html("\\url{a\nb}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\url{}`.
      [31m✖[39m This may be caused by a \url tag that spans a line break.
    Code
      rd2html("\\email{}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\email{}`.
      [31m✖[39m empty
    Code
      rd2html("\\linkS4class{}")
    Condition
      [1m[33mError[39m in `purrr::map_chr()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\linkS4class{}`.

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

