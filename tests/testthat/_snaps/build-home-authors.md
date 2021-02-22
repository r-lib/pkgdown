# Data authors can accept different filtering

    Code
      data_authors(pkg)$main
    Output
      [[1]]
      [[1]]$name
      [1] "<a href='http://hadley.nz'>Hadley Wickham</a>"
      
      [[1]]$roles
      [1] "Author, maintainer"
      
      [[1]]$comment
      NULL
      
      [[1]]$orcid
      NULL
      
      
      [[2]]
      [[2]]$name
      [1] "<a href='https://www.rstudio.com'><img src='https://www.tidyverse.org/rstudio-logo.svg' alt='RStudio' height='24' /></a>"
      
      [[2]]$roles
      [1] "Copyright holder, funder"
      
      [[2]]$comment
      NULL
      
      [[2]]$orcid
      NULL
      
      

---

    Code
      data_authors(pkg, roles = "cre")$main
    Output
      [[1]]
      [[1]]$name
      [1] "<a href='http://hadley.nz'>Hadley Wickham</a>"
      
      [[1]]$roles
      [1] "Author, maintainer"
      
      [[1]]$comment
      NULL
      
      [[1]]$orcid
      NULL
      
      

# Text can be added

    Code
      data_authors_page(pkg)$before
    Output
      [1] "<p>Dream team:</p>"

---

    Code
      data_authors_page(pkg)$after
    Output
      [1] "<p>And <strong><em>thanks</em></strong> to <a href=\"news/index.html\">contributors</a>!</p>"

