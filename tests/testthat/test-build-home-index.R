test_that("messages about reading and writing", {
  pkg <- local_pkgdown_site()

  expect_snapshot({
    build_home_index(pkg)
    build_home_index(pkg)
  })
})

test_that("title and description come from DESCRIPTION by default", {
  pkg <- as_pkgdown(test_path("assets/home-index-rmd"))
  expect_equal(data_home(pkg)$pagetitle, "A test package")
  expect_equal(data_home(pkg)$opengraph$description, "A test package")

  pkg$meta <- list(home = list(title = "X", description = "Y"))
  expect_equal(data_home(pkg)$pagetitle, "X")
  expect_equal(data_home(pkg)$opengraph$description, "Y")
})

test_that("math is handled", {
  pkg <- local_pkgdown_site()
  write_lines(c("$1 + 1$"), path(pkg$src_path, "README.md"))
  suppressMessages(build_home_index(pkg))

  html <- xml2::read_html(path(pkg$dst_path, "index.html"))
  expect_equal(xpath_length(html, ".//math"), 1)
})

test_that("data_home() validates yaml metadata", {  
  data_home_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    data_home(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_home_(home = 1)
    data_home_(home = list(title = 1))
    data_home_(home = list(description = 1))
    data_home_(template = list(trailing_slash_redirect = 1))
  })
})

test_that("version formatting in preserved", {
  pkg <- local_pkgdown_site(test_path("assets/version-formatting"))
  expect_equal(pkg$version, "1.0.0-9000")

  suppressMessages(init_site(pkg))
  suppressMessages(build_home_index(pkg))
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
  suppressMessages(init_site(pkg))
  pkg$meta$home$sidebar <- FALSE
  # not built by data_home_sidebar()
  expect_false(data_home_sidebar(pkg))

  # nor later -- so probably not to be tested here?!
  dir_create(path(pkg$dst_path))
  suppressMessages(build_home_index(pkg))
  html <- xml2::read_html(path(pkg$dst_path, "index.html"))
  expect_equal(xpath_length(html, ".//aside/*"), 0)
})

test_that("data_home_sidebar() can be defined by a HTML file", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  pkg$meta$home$sidebar$html <- "sidebar.html"
  expect_equal(
    data_home_sidebar(pkg),
    read_file(path(pkg$src_path, "sidebar.html"))
  )
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
  data_home_sidebar_ <- function(...) {
    pkg$meta$home$sidebar <- list(...)
    data_home_sidebar(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_home_sidebar_(html = 1)
    data_home_sidebar_(structure = 1)
    data_home_sidebar_(structure = "fancy")
    data_home_sidebar_(structure = c("fancy", "cool"))
    data_home_sidebar_(structure = "fancy", components = list(fancy = list(text = "bla")))
    data_home_sidebar_(structure = "fancy", components = list(fancy = list()))
  })
})

test_that("data_home_sidebar() errors well when no HTML file", {
  pkg <- as_pkgdown(test_path("assets/sidebar"))
  pkg$meta$home$sidebar$html <- "file.html"
  expect_snapshot(data_home_sidebar(pkg), error = TRUE)
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
