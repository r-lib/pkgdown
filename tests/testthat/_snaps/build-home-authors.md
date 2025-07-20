# data_authors validates yaml inputs

    Code
      data_authors_(authors = 1)
    Condition
      Error in `data_authors_()`:
      ! In _pkgdown.yml, authors must be a list, not the number 1.
    Code
      data_authors_(authors = list(before = 1))
    Condition
      Error in `data_authors_()`:
      ! In _pkgdown.yml, authors.before must be a string, not the number 1.
    Code
      data_authors_(authors = list(after = 1))
    Condition
      Error in `data_authors_()`:
      ! In _pkgdown.yml, authors.after must be a string, not the number 1.

# data_home_sidebar_authors validates yaml inputs

    Code
      data_home_sidebar_authors_(authors = list(sidebar = list(roles = 1)))
    Condition
      Error in `data_home_sidebar_authors_()`:
      ! In _pkgdown.yml, authors.sidebar.roles must be a character vector, not the number 1.
    Code
      data_home_sidebar_authors_(authors = list(sidebar = list(before = 1)))
    Condition
      Error in `data_home_sidebar_authors_()`:
      ! In _pkgdown.yml, authors.sidebar.before must be a string, not the number 1.
    Code
      data_home_sidebar_authors_(authors = list(sidebar = list(before = "x\n\ny")))
    Condition
      Error in `data_home_sidebar_authors_()`:
      ! In _pkgdown.yml, authors.sidebar.before must be inline markdown.

# sidebar can accept additional before and after text

    Code
      cat(data_home_sidebar_authors(pkg))
    Output
      <div class='developers'>
      <h2 data-toc-skip>Developers</h2>
      <ul class='list-unstyled'>
      <li>BEFORE</li>
      <li>Jo Doe <br />
      <small class = 'roles'> Author, maintainer </small>   </li>
      <li>AFTER</li>
      </ul>
      </div>

# role has multiple fallbacks

    Code
      role_lookup("unknown")
    Condition
      Warning:
      Unknown MARC role abbreviation: unknown
    Output
      [1] "unknown"

# multiple citations all have HTML and BibTeX formats

    [[1]]
    [[1]]$html
    [1] "<p>A &amp; B (2021): Proof of b &lt; a &gt; c.</p>"
    
    [[1]]$bibtex
    [1] "@Misc{,\n  title = {Proof of b < a > c},\n  author = {{A} and {B}},\n  year = {2021},\n}"
    
    
    [[2]]
    [[2]]$html
    [1] "<p>Two A (2022).\n&ldquo;Title Two.&rdquo; \n</p>"
    
    [[2]]$bibtex
    [1] "@Misc{,\n  title = {Title Two},\n  author = {Author Two},\n  year = {2022},\n}"
    
    

