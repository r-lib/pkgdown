test_that("navbar_links_haystack()", {
  html <- xml2::read_html('
    <div class="navbar-collapse">
    <ul>
      <li class="nav-item"><a href="articles/pkgdown.html">Get started</a></li>
      <li class="nav-item"><a href="reference/index.html">Reference</a></li>
      <li class="nav-item dropdown">
        <a href="#" class="nav-link dropdown-toggle">Articles</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
          <a class="dropdown-item" href="articles/index.html">More</a>
        </div>
      </li>
    </ul>
    </div>
  ')

  best_match <- function(path) {
    navbar_links_haystack(html, pkg = list(), path)[1, c("links", "similar")]
  }

  # Link to exact path if present
  expect_equal(
    best_match("articles/pkgdown.html"),
    tibble::tibble(links = "articles/pkgdown.html", similar = 2)
  )
  # even if in sub-menu
  expect_equal(
    best_match("articles/linking.html"),
    tibble::tibble(links = "articles/linking.html", similar = 2)
  )

  # ignores index.html
  expect_equal(
    best_match("articles/index.html"),
    tibble::tibble(links = "articles", similar = 1)
  )

  # If not present, guess at top-level home
  expect_equal(
    best_match("articles/bla.html"),
    tibble::tibble(links = "articles", similar = 1)
  )
})

test_that("activation sets class of best match", {
  html <- xml2::read_html('
    <div class="navbar-collapse">
    <ul>
      <li class="nav-item"><a href="articles/pkgdown.html">Get started</a></li>
      <li class="nav-item"><a href="reference/index.html">Reference</a></li>
      <li class="nav-item dropdown">
        <a href="#" class="nav-link dropdown-toggle">Articles</a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
          <a class="dropdown-item" href="articles/linking.html">Auto-linking</a>
          <a class="dropdown-item" href="articles/index.html">More</a>
        </div>
      </li>
    </ul>
    </div>
  ')

  activate_navbar(html, "articles/linking.html")
  expect_equal(
    xpath_attr(html, "//li", "class"),
    c("nav-item", "nav-item", "active nav-item dropdown")
  )
})
