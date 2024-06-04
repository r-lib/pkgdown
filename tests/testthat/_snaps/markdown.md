# markdown_text_inline() works with inline markdown

    Code
      markdown_text_inline(pkg, "x\n\ny", error_path = "title")
    Condition
      Error:
      ! In _pkgdown.yml, title must be inline markdown.

# validates math yaml

    Code
      config_math_rendering_(`math-rendering` = 1)
    Condition
      Error in `config_math_rendering_()`:
      ! In _pkgdown.yml, template.math-rendering must be a string, not the number 1.
    Code
      config_math_rendering_(`math-rendering` = "math")
    Condition
      Error in `config_math_rendering_()`:
      ! In _pkgdown.yml, template.math-rendering must be one of mathml, mathjax, and katex, not math.

