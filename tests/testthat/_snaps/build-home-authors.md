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

# role has multiple fallbacks [plain]

    Code
      role_lookup("unknown")
    Condition
      Warning:
      Unknown MARC role abbreviation: unknown
    Output
      [1] "unknown"

# role has multiple fallbacks [ansi]

    Code
      role_lookup("unknown")
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mUnknown MARC role abbreviation: [32munknown[39m
    Output
      [1] "unknown"

# role has multiple fallbacks [unicode]

    Code
      role_lookup("unknown")
    Condition
      Warning:
      Unknown MARC role abbreviation: unknown
    Output
      [1] "unknown"

# role has multiple fallbacks [fancy]

    Code
      role_lookup("unknown")
    Condition
      [1m[33mWarning[39m:[22m
      [1m[22mUnknown MARC role abbreviation: [32munknown[39m
    Output
      [1] "unknown"

