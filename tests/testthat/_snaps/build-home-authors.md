# data_home_sidebar_authors() works with text

    Code
      cat(data_home_sidebar_authors(pkg))
    Output
      <div class='developers'>
      <h2 data-toc-skip>Developers</h2>
      <ul class='list-unstyled'>
      <li>yay</li>
      <li><a href='http://hadley.nz'>Hadley Wickham</a> <br />
      <small class = 'roles'> Author, maintainer </small>  </li>
      <li><a href='https://www.rstudio.com'><img src="https://www.tidyverse.org/rstudio-logo.svg" alt="RStudio" width="72"></a> <br />
      <small class = 'roles'> Copyright holder, funder </small>  </li>
      <li>cool</li>
      <li><a href='authors.html'>More about authors...</a></li>
      </ul>
      </div>

# role has multiple fallbacks

    Code
      role_lookup("unknown")
    Warning <rlang_warning>
      Unknown MARC role abbreviation 'unknown'
    Output
      [1] "unknown"

