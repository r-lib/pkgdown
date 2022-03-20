test_that("title and description come from DESCRIPTION by default", {
  pkg <- as_pkgdown(test_path("assets/home-index-rmd"))
  expect_equal(data_home(pkg)$pagetitle, "A test package")
  expect_equal(data_home(pkg)$opengraph$description, "A test package")

  pkg$meta <- list(home = list(title = "X", description = "Y"))
  expect_equal(data_home(pkg)$pagetitle, "X")
  expect_equal(data_home(pkg)$opengraph$description, "Y")
})

test_that("version formatting in preserved", {
  pkg <- local_pkgdown_site(test_path("assets/version-formatting"))
  expect_equal(pkg$version, "1.0.0-9000")

  expect_output(init_site(pkg))
  build_home_index(pkg, quiet = TRUE)
  index <- read_lines(path(pkg$dst_path, "index.html"))
  expect_true(any(grepl("1.0.0-9000", index, fixed = TRUE)))
})

test_that("data_home_sidebar() works by default", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  expect_snapshot(cat(data_home_sidebar(pkg)))

  pkg <- as_pkgdown(test_path("assets/sidebar-comment"))
  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot_output(xpath_xml(html, ".//div[@class='developers']"))
})

test_that("data_home_sidebar() can be removed", {
  pkg <- local_pkgdown_site(test_path("assets/sidebar"))
  pkg$meta$home$sidebar <- FALSE
  # not built by data_home_sidebar()
  expect_false(data_home_sidebar(pkg))

  # nor later -- so probably not to be tested here?!
  dir_create(path(pkg$dst_path))
  build_home_index(pkg)
  html <- xml2::read_html(path(pkg$dst_path, "index.html"))
  expect_equal(xpath_length(html, ".//aside/*"), 0)
})

test_that("data_home_sidebar() can be defined by a HTML file", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  pkg$meta$home$sidebar$html <- "sidebar.html"
  expect_equal(
    data_home_sidebar(pkg),
    read_file(file.path(pkg$src_path, "sidebar.html"))
  )
})

test_that("data_home_sidebar() errors well when no HTML file", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  pkg$meta$home$sidebar$html <- "file.html"
  expect_snapshot_error(data_home_sidebar(pkg))
})

test_that("data_home_sidebar() can get a custom markdown formatted component", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  pkg$meta$home$sidebar <- list(
    structure = "fancy",
    components = list(
      fancy = list(
        title = "Fancy section",
        text = "How *cool* is pkgdown?!"
      )
    )
  )

  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot_output(xpath_xml(html, ".//div[@class='fancy-section']"))
})

test_that("data_home_sidebar() can add a README", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  pkg$meta$home$sidebar <- list(structure = c("license", "toc"))

  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot_output(xpath_xml(html, ".//div[@class='table-of-contents']"))
})

test_that("data_home_sidebar() outputs informative error messages", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))

  # no component definition for a component named in structure
  pkg$meta$home$sidebar <- list(structure = "fancy")
  expect_snapshot_error(data_home_sidebar(pkg))

  # no component definition for two components named in structure
  pkg$meta$home$sidebar <- list(structure = c("fancy", "cool"))
  expect_snapshot_error(data_home_sidebar(pkg))

  # no title
  pkg$meta$home$sidebar <- list(
    structure = c("fancy"),
    components = list(fancy = list(text = "bla"))
  )
  expect_snapshot_error(data_home_sidebar(pkg))

  # no title nor text
  pkg$meta$home$sidebar <- list(
    structure = c("fancy"),
    components = list(fancy = list(html = "bla"))
  )
  expect_snapshot_error(data_home_sidebar(pkg))
})

test_that("package repo verification", {
  skip_on_cran() # requires internet connection

  expect_null(cran_link("notarealpkg"))
  expect_equal(
    cran_link("dplyr"),
    list(repo = "CRAN", url = "https://cloud.r-project.org/package=dplyr")
  )
  expect_equal(
    cran_link("Biobase"),
    list(repo = "Bioconductor", url = "https://www.bioconductor.org/packages/Biobase")
  )
})
