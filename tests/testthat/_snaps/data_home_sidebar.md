# data_home_sidebar() works by default

    Code
      cat(data_home_sidebar(pkg))
    Output
      <div class='license'>
      <h2>License</h2>
      <ul class='list-unstyled'>
      <li>NA</li>
      </ul>
      </div>
      
      
      <div class='developers'>
      <h2>Developers</h2>
      <ul class='list-unstyled'>
      <li><a href='http://hadley.nz'>Hadley Wickham</a> <br />
      <small class = 'roles'> Author, maintainer </small>  </li>
      <li><a href='https://www.rstudio.com'><img src='https://www.tidyverse.org/rstudio-logo.svg' alt='RStudio' height='24'></img></a> <br />
      <small class = 'roles'> Copyright holder, funder </small>  </li>
      </ul>
      </div>
      
      <div class='dev-status'>
      <h2>Dev Status</h2>
      <ul class='list-unstyled'>
      <li>placeholder</li>
      </ul>
      </div>

# data_home_sidebar() errors well when no HTML file

    Can't find file 'file.html' specified by home.sidebar.html in '_pkgdown.yml'.

# data_home_sidebar() can get a custom component

    Code
      xml2::xml_find_first(xml2::xml_find_first(result,
        ".//div[@class='fancy-section']"), ".//ul")
    Output
      {html_node}
      <ul class="list-unstyled">
      [1] <li>How cool is  <a href="https://pkgdown.r-lib.org">pkgdown</a>  1.0.0?! ...

# data_home_sidebar() outputs informative error messages

    Can't find component home.sidebar.components.fancy in '_pkgdown.yml'.

---

    Can't find components home.sidebar.components.fancy, home.sidebar.components.cool in '_pkgdown.yml'.

---

    Can't find title for the component home.sidebar.components.fancy in '_pkgdown.yml'

---

    Can't find title nor text for the component home.sidebar.components.fancy in '_pkgdown.yml'

