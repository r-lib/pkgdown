# markdown_text_inline() works with inline markdown

    Code
      markdown_text_inline("x\n\ny", error_pkg = pkg, error_path = "title")
    Condition
      Error:
      ! title must be inline markdown.
      i Edit _pkgdown.yml to fix the problem.

