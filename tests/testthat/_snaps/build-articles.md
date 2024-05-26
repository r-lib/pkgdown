# validates articles yaml

    Code
      data_articles_index_(1)
    Condition
      Error in `data_articles_index_()`:
      ! articles must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(1))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1] must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list()))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1] must have components "title" and "contents".
      2 missing components: "title" and "contents".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list(title = 1, contents = 1)))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1].title must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list(title = "a\n\nb", contents = 1)))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1].title must be inline markdown.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_index_(list(list(title = "a", contents = 1)))
    Condition
      Error in `data_articles_index_()`:
      ! articles[1].contents[1] must be a string.
      i You might need to add '' around special YAML values like 'N' or 'off'
      i Edit _pkgdown.yml to fix the problem.

# validates external-articles

    Code
      data_articles_(1)
    Condition
      Error in `data_articles_()`:
      ! external-articles must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(1))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1] must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1] must have components "name", "title", "href", and "description".
      3 missing components: "title", "href", and "description".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = 1, title = "x", href = "x", description = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].name must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x", title = 1, href = "x", description = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].title must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x", title = "x", href = 1, description = "x")))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].href must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_articles_(list(list(name = "x", title = "x", href = "x", description = 1)))
    Condition
      Error in `data_articles_()`:
      ! external-articles[1].description must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.

# articles in vignettes/articles/ are unnested into articles/

    Code
      build_redirects(pkg)
    Message
      -- Building redirects ----------------------------------------------------------
      Adding redirect from articles/articles/nested.html to articles/nested.html.

# warns about articles missing from index

    Code
      . <- data_articles_index(pkg)
    Condition
      Error:
      ! 1 vignette missing from index: "c".
      i Edit _pkgdown.yml to fix the problem.

