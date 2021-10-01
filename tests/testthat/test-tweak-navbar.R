
test_that("navbar_links_haystack()", {
  html <- function(){
  xml2::read_html('<div id="navbar" class="collapse navbar-collapse">
      <ul class="navbar-nav mr-auto ml-3">
<li class="nav-item">
  <a class="nav-link" href="articles/pkgdown.html">Get started</a>
</li>
<li class="nav-item">
  <a class="nav-link" href="reference/index.html">Reference</a>
</li>
<li class="nav-item dropdown">
  <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true">Articles</a>
  <div class="dropdown-menu" aria-labelledby="navbarDropdown">
    <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
    <a class="dropdown-item" href="articles/index.html">More</a>
      </div>
</li>
      </ul>
</div>')
  }
  expect_snapshot(
    navbar_links_haystack(html(), pkg = list(), path = "articles/bla.html")[, c("links", "similar")]
  )
  expect_snapshot(
    navbar_links_haystack(html(), pkg = list(), path = "articles/linking.html")[, c("links", "similar")]
  )
  expect_snapshot(
    navbar_links_haystack(html(), pkg = list(), path = "articles/pkgdown.html")[, c("links", "similar")]
  )
})

test_that("activate_navbar()", {
  html <- function(){
  xml2::read_html('<div id="navbar" class="collapse navbar-collapse">
      <ul class="navbar-nav mr-auto ml-3">
<li class="nav-item">
  <a class="nav-link" href="articles/pkgdown.html">Get started</a>
</li>
<li class="nav-item">
  <a class="nav-link" href="reference/index.html">Reference</a>
</li>
<li class="nav-item dropdown">
  <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false" aria-haspopup="true">Articles</a>
  <div class="dropdown-menu" aria-labelledby="navbarDropdown">
    <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
    <a class="dropdown-item" href="articles/index.html">More</a>
      </div>
</li>
      </ul>
</div>')
  }
  navbar <- html()
  activate_navbar(navbar, "reference/index.html", pkg = list())
  expect_snapshot_output(
    xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )


  navbar <- html()
  activate_navbar(navbar, "reference/thing.html", pkg = list())
 expect_snapshot_output(
    xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )
  navbar <- html()
  activate_navbar(navbar, "articles/pkgdown.html", pkg = list())
  expect_snapshot_output(
    xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )

  navbar <- html()
  activate_navbar(navbar, "articles/thing.html", pkg = list())
  expect_snapshot_output(
      xml2::xml_find_first(navbar, ".//li[contains(@class, 'active')]")
  )
})
