# data_home_sidebar_authors() works with text

    Code
      cat(data_home_sidebar_authors(pkg))
    Output
      <div class='developers'>
      <h2 data-toc-skip>Developers</h2>
      <ul class='list-unstyled'>
      <li>yay</li>
      <li>Hadley Wickham <br />
      <small class = 'roles'> Author, maintainer </small>  </li>
      <li>RStudio <br />
      <small class = 'roles'> Copyright holder, funder </small>  </li>
      <li>cool</li>
      <li><a href='authors.html'>More about authors...</a></li>
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

# source link is added to citation page

    Code
      build_home(pkg)
    Message
      -- Building home ---------------------------------------------------------------
      Writing `authors.html`
      Writing `404.html`

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
    
    

