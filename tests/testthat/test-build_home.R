context("build_home")


# license -----------------------------------------------------------------

test_that("link_license matchs exactly", {
  # Shouldn't match first GPL-2
  expect_equal(
    autolink_license("LGPL-2") ,
    "<a href='https://www.r-project.org/Licenses/LGPL-2'>LGPL-2</a>"
  )
})

test_that("link_license matches LICENSE", {
  expect_equal(
    autolink_license("LICENSE") ,
    "<a href='LICENSE-text.html'>LICENSE</a>"
  )
})


# index -------------------------------------------------------------------

test_that("intermediate files cleaned up automatically", {
  pkg <- test_path("home-index-rmd")
  expect_output(build_home(pkg))
  on.exit(clean_site(pkg))

  expect_equal(sort(dir(pkg)), sort(c("docs", "DESCRIPTION", "index.Rmd")))
})

test_that("intermediate files cleaned up automatically", {
  pkg <- test_path("home-readme-rmd")
  expect_output(build_home(pkg))
  on.exit(clean_site(pkg))

  expect_equal(sort(dir(pkg)), sort(c("docs", "DESCRIPTION", "README.md", "README.Rmd")))
})


# tweaks ------------------------------------------------------------------

test_that("page header modification succeeds", {
  html <- xml2::read_html('
    <h1 class="hasAnchor">
      <a href="#plot" class="anchor"> </a>
      <img src="someimage" alt=""> some text
    </h1>')

  tweak_homepage_html(html)

  expect_output_file(cat(as.character(html)), "home-page-header.html")
})

test_that("links to vignettes & figures tweaked", {
  html <- xml2::read_html('
    <img src="vignettes/x.png" />
    <img src="man/figures/x.png" />
  ')

  tweak_homepage_html(html)

  expect_output_file(cat(as.character(html)), "home-links.html")
})

# repo_link ------------------------------------------------------------

test_that("package repo verification", {
  skip_on_cran() # requires internet connection

  expect_null(repo_link("notarealpkg"))

  expect_equal(
    repo_link("dplyr"),
    list(
      repo = "CRAN",
      url = "https://cloud.r-project.org/package=dplyr"
    )
  )

  expect_equal(
    repo_link("Biobase"),
    list(
      repo = "BIOC",
      url = "https://www.bioconductor.org/packages/Biobase"
    )
  )
})

# orcid ------------------------------------------------------------------

test_that("ORCID can be identified from all comment styles", {
  pkg <- as_pkgdown(test_path("site-orcid"))
  author_info <- data_author_info(pkg)
  authors <- pkg %>%
    pkg_authors() %>%
    purrr::map(author_list, author_info)
  expect_length(authors, 5)
})

test_that("names can be removed from persons", {
  p0 <- person("H", "W")
  p1 <- person("H", "W", role = "ctb", comment = "one")
  p2 <- person("H", "W", comment = c("one", "two"))
  p3 <- person("H", "W", comment = c("one", ORCID = "orcid"))
  p4 <- person("H", "W", comment = c(ORCID = "orcid"))
  p5 <- person("H", "W", comment = c(ORCID = "orcid1", ORCID = "orcid2"))

  expect_null(remove_name(p0$comment, "ORCID"))
  expect_equal(remove_name(p1$comment, "ORCID"), "one")
  expect_equal(remove_name(p2$comment, "ORCID"), c("one", "two"))
  expect_length(remove_name(p3$comment, "ORCID"), 1)
  expect_length(remove_name(p4$comment, "ORCID"), 0)
  expect_length(remove_name(p5$comment, "ORCID"), 0)
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

# empty readme.md ---------------------------------------------------------

test_that("build_home fails with empty readme.md", {
  pkg <- test_path("home-empty-readme-md")
  on.exit(clean_site(pkg))

  expect_output(
    expect_error(build_home(pkg), "non-empty")
  )
})
