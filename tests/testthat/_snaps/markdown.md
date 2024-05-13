# markdown_text_inline() works with inline markdown

    Code
      markdown_text_inline("x\n\ny", pkg = pkg)
    Condition
      Error:
      ! <inline> must supply an inline element, not a block element.
      i Edit _pkgdown.yml to fix the problem.

