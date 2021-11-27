# data_home_sidebar() works by default

    Code
      cat(data_home_sidebar(pkg))
    Output
      <div class='license'>
      <h2 data-toc-skip>License</h2>
      <ul class='list-unstyled'>
      <li><a href='https://www.r-project.org/Licenses/GPL-3'>GPL-3</a></li>
      </ul>
      </div>
      
      
      <div class='citation'>
      <h2 data-toc-skip>Citation</h2>
      <ul class='list-unstyled'>
      <li><a href='authors.html#citation'>Citing testpackage</a></li>
      </ul>
      </div>
      
      <div class='developers'>
      <h2 data-toc-skip>Developers</h2>
      <ul class='list-unstyled'>
      <li><a href='http://hadley.nz'>Hadley Wickham</a> <br />
      <small class = 'roles'> Author, maintainer </small>  </li>
      <li><a href='https://www.rstudio.com'><img src="https://www.tidyverse.org/rstudio-logo.svg" alt="RStudio" width="72"></a> <br />
      <small class = 'roles'> Copyright holder, funder </small>  </li>
      </ul>
      </div>
      
      <div class='dev-status'>
      <h2 data-toc-skip>Dev Status</h2>
      <ul class='list-unstyled'>
      <li>placeholder</li>
      </ul>
      </div>

---

    <div class="developers">
    <h2 data-toc-skip>Developers</h2>
    <ul class="list-unstyled">
    <li>
    <a href="http://hadley.nz">Hadley Wickham</a> <br><small class="roles"> Author, maintainer </small>  </li>
    <li>
    <a href="https://www.rstudio.com"><img src="https://www.tidyverse.org/rstudio-logo.svg" alt="RStudio" width="72"></a> <br><small class="roles"> Copyright holder, funder </small>  </li>
    <li><a href="authors.html">More about authors...</a></li>
    </ul>
    </div>

# data_home_sidebar() errors well when no HTML file

    Can't find file 'file.html' specified by home.sidebar.html in '_pkgdown.yml'.

# data_home_sidebar() can get a custom markdown formatted component

    <div class="fancy-section">
    <h2 data-toc-skip>Fancy section</h2>
    <ul class="list-unstyled">
    <li><p>How <em>cool</em> is pkgdown?!</p></li>
    </ul>
    </div>

# data_home_sidebar() can add a README

    <div class="table-of-contents">
    <h2 data-toc-skip>Table of contents</h2>
    <ul class="list-unstyled">
    <li><nav id="toc"></nav></li>
    </ul>
    </div>

# data_home_sidebar() outputs informative error messages

    Can't find component home.sidebar.components.fancy in '_pkgdown.yml'.

---

    Can't find components home.sidebar.components.fancy, home.sidebar.components.cool in '_pkgdown.yml'.

---

    Can't find component home.sidebar.components.fancy.title in '_pkgdown.yml'.

---

    Can't find components home.sidebar.components.fancy.title, home.sidebar.components.fancy.text in '_pkgdown.yml'.

