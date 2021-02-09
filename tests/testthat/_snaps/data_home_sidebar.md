# data_home_sidebar() works by default

    Code
      data_home_sidebar(pkg)
    Output
      [1] "character(0)\n<div class='license'>\n<h2>License</h2>\n<ul class='list-unstyled'>\n<li>NA</li>\n</ul>\n</div>\n\n\ncharacter(0)\n<div class='developers'>\n<h2>Developers</h2>\n<ul class='list-unstyled'>\n<li><a href='http://hadley.nz'>Hadley Wickham</a> <br />\n<small class = 'roles'> Author, maintainer </small>  </li>\n<li><a href='https://www.rstudio.com'><img src='https://www.tidyverse.org/rstudio-logo.svg' alt='RStudio' height='24' /></a> <br />\n<small class = 'roles'> Copyright holder, funder </small>  </li>\n</ul>\n</div>\n\n<div class='dev-status'>\n<h2>Dev Status</h2>\n<ul class='list-unstyled'>\n<li>placeholder</li>\n</ul>\n</div>\n"

# data_home_sidebar() errors well when no HTML file

    Can't find file file.html that was indicated in home.sidebar.html in '_pkgdown.yml' (or in the `override` parameter).

# data_home_sidebar() can get a custom component

    Code
      xml2::xml_find_first(result, ".//div[@class='fancy-section']")
    Output
      {html_node}
      <div class="fancy-section">
      [1] <h2>Fancy section</h2>
      [2] <ul class="list-unstyled">\n<li>How cool is pkgdown?!</li>\n</ul>

# data_home_sidebar() outputs informative error messages

    There is no component named fancy in home.sidebar.components in '_pkgdown.yml' (or in the `override` parameter).

---

    Missing title for the component fancy in home.sidebar.components in '_pkgdown.yml' (or in the `override` parameter)

