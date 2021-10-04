test_that("Stripping HTML tags", {
  expect_identical(
    strip_html_tags("<p>some text about <code>data</code>"),
    "some text about data"
  )
})

# links and references in the package description -------------------------

test_that("references in angle brackets are converted to HTML", {
  ## URL
  expect_identical(
    linkify("see <https://CRAN.R-project.org/view=SpatioTemporal>."),
    "see &lt;<a href='https://CRAN.R-project.org/view=SpatioTemporal'>https://CRAN.R-project.org/view=SpatioTemporal</a>&gt;."
  )
  ## DOI
  expect_identical(
    linkify("M & H (2017) <doi:10.1093/biostatistics/kxw051>"),
    "M &amp; H (2017) &lt;<a href='https://doi.org/10.1093/biostatistics/kxw051'>doi:10.1093/biostatistics/kxw051</a>&gt;"
  )
  ## arXiv
  expect_identical(
    linkify("see <arXiv:1802.03967>."),
    "see &lt;<a href='https://arxiv.org/abs/1802.03967'>arXiv:1802.03967</a>&gt;."
  )
  ## unsupported formats are left alone (just escaping special characters)
  unsupported <- c(
    "<doi:10.1002/(SICI)1097-0258(19980930)17:18<2045::AID-SIM943>3.0.CO;2-P>",
    "<https://scholar.google.com/citations?view_op=top_venues&hl=de&vq=phy_probabilitystatistics>"
  )
  expect_identical(linkify(unsupported), escape_html(unsupported))
})
