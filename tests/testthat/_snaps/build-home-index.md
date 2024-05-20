# data_home() validates yaml metadata

    Code
      data_home_(home = 1)
    Condition
      Error in `data_home_()`:
      ! home must be a list, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_(home = list(title = 1))
    Condition
      Error in `data_home_()`:
      ! home.title must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_(home = list(description = 1))
    Condition
      Error in `data_home_()`:
      ! home.description must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_(template = list(trailing_slash_redirect = 1))
    Condition
      Error in `data_home_()`:
      ! template.trailing_slash_redirect must be true or false, not the number 1.
      i Edit _pkgdown.yml to fix the problem.

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
      <li>Hadley Wickham <br />
      <small class = 'roles'> Author, maintainer </small>  </li>
      <li>RStudio <br />
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
    <li>Hadley Wickham <br><small class="roles"> Author, maintainer </small>  </li>
    <li>RStudio <br><small class="roles"> Copyright holder, funder </small>  </li>
    <li><a href="authors.html">More about authors...</a></li>
    </ul>
    </div>

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

    Code
      data_home_sidebar_(html = 1)
    Condition
      Error in `data_home_sidebar_()`:
      ! home.sidebar.html must be a string, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_sidebar_(structure = 1)
    Condition
      Error in `data_home_sidebar_()`:
      ! home.sidebar.structure must be a character vector, not the number 1.
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_sidebar_(structure = "fancy")
    Condition
      Error in `data_home_sidebar_()`:
      ! home.sidebar.components must have component "fancy".
      1 missing component: "fancy".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_sidebar_(structure = c("fancy", "cool"))
    Condition
      Error in `data_home_sidebar_()`:
      ! home.sidebar.components must have components "fancy" and "cool".
      2 missing components: "fancy" and "cool".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_sidebar_(structure = "fancy", components = list(fancy = list(text = "bla")))
    Condition
      Error in `data_home_sidebar_()`:
      ! home.sidebar.components.fancy must have components "title" and "text".
      1 missing component: "title".
      i Edit _pkgdown.yml to fix the problem.
    Code
      data_home_sidebar_(structure = "fancy", components = list(fancy = list()))
    Condition
      Error in `data_home_sidebar_()`:
      ! home.sidebar.components.fancy must have components "title" and "text".
      2 missing components: "title" and "text".
      i Edit _pkgdown.yml to fix the problem.

# data_home_sidebar() errors well when no HTML file

    Code
      data_home_sidebar(pkg)
    Condition
      Error:
      ! home.sidebar.html specifies a file that doesn't exist ('file.html').
      i Edit _pkgdown.yml to fix the problem.

