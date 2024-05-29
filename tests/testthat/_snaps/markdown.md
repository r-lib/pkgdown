# markdown_text_inline() works with inline markdown

    Code
      markdown_text_inline(pkg, "x\n\ny", error_path = "title")
    Condition
      Error:
      ! title must be inline markdown.
      i Edit _pkgdown.yml to fix the problem.

# validates math yaml

    Code
      config_math_rendering_(`math-rendering` = 1)
    Condition
      Error in `config_math_rendering_()`:
      ! template.math-rendering must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      config_math_rendering_(`math-rendering` = "math")
    Condition
      Error in `config_math_rendering_()`:
      ! template.math-rendering must be one of mathml, mathjax, and katex, not math.
      i Edit _pkgdown.yml to fix the problem.

