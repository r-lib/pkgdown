# homepage ----------------------------------------------------------------

test_that("page header modification succeeds", {
  html <- xml2::read_xml('
    <h1 class="hasAnchor">
      <a href="#plot" class="anchor"> </a>
      <img src="someimage" alt="" /> some text
    </h1>')

  tweak_homepage_html(html, bs_version = 3)
  expect_snapshot_output(show_xml(html))
})

test_that("links to vignettes & figures tweaked", {
  html <- xml2::read_xml('<body>
    <img src="vignettes/x.png" />
    <img src="man/figures/x.png" />
  </body>')

  tweak_homepage_html(html, bs_version = 3)
  expect_snapshot_output(show_xml(html))
})

