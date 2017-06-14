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
    "<a href='LICENSE.html'>LICENSE</a>"
  )
})


# index -------------------------------------------------------------------

test_that("can build package without any index/readme", {
  expect_error(
    build_home(test_path("home-empty"), tempdir()),
    NA
  )
})

test_that("intermediate files cleaned up automatically", {
  pkg <- test_path("home-index-rmd")
  build_home(pkg, tempdir())

  expect_equal(dir(pkg), c("DESCRIPTION", "index.Rmd"))
})

test_that("intermediate files cleaned up automatically", {
  pkg <- test_path("home-readme-rmd")
  build_home(pkg, tempdir())

  expect_equal(sort(dir(pkg)), sort(c("DESCRIPTION", "README.md", "README.Rmd")))
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


# cran --------------------------------------------------------------------


test_that("package CRAN verification", {

  expect_true(in_repo("dplyr"))
  expect_true(in_repo("dplyr", cran = "https://cloud.r-project.org"))

  expect_false(in_repo("notarealpkg"))
  expect_false(in_repo("notarealpkg", "https://cloud.r-project.org"))

})

