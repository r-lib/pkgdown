# repo_link ------------------------------------------------------------

test_that("package repo verification", {
  skip_on_cran() # requires internet connection

  expect_null(cran_link("notarealpkg"))

  expect_equal(
    cran_link("dplyr"),
    list(
      repo = "CRAN",
      url = "https://cloud.r-project.org/package=dplyr"
    )
  )

  expect_equal(
    cran_link("Biobase"),
    list(
      repo = "BIOC",
      url = "https://www.bioconductor.org/packages/Biobase"
    )
  )
})

test_that("homepage title defaults to package Title", {
  pkg <- test_path("assets/home-index-rmd")
  expect_equal(
    as.character(data_home(pkg))[[1]],
    "A test package"
  )
})

test_that("homepage title can be overridden", {
  pkg <- test_path("assets/home-index-rmd")
  pkg <- as_pkgdown(pkg)
  pkg$meta <- list(home = list(
    title = "Such a cool package"))

  expect_equal(
    as.character(data_home(pkg))[[1]],
    "Such a cool package"
  )

})

test_that("homepage description defaults to package Description", {
  pkg <- test_path("assets/home-index-rmd")
  expect_true(
    grepl("A test package",
    as.character(data_home(pkg))[[3]],
  )
  )
})

test_that("homepage description can be overridden", {
  pkg <- test_path("assets/home-index-rmd")
  pkg <- as_pkgdown(pkg)
  pkg$meta <- list(home = list(
    description = "A free description."))

  expect_true(
    grepl("A free description.",
          as.character(data_home(pkg))[[3]],
    )
  )

})

test_that("formatting in DESCRIPTION version is preserved", {
  pkg <- as_pkgdown(test_path("assets/version-formatting"))
  expect_equal(pkg$version, "1.0.0-9000")

  expect_output(init_site(pkg))
  build_home_index(pkg, quiet = TRUE)
  index <- read_lines(path(pkg$dst_path, "index.html"))
  expect_true(any(grepl("1.0.0-9000", index, fixed = TRUE)))
})

test_that("data_home_sidebar() works by default", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  expect_snapshot(cat(data_home_sidebar(pkg)))

  pkg <- test_path("assets/sidebar-comment")
  pkg <- as_pkgdown(pkg)
  expect_snapshot(
    cat(
      as.character(
        xml2::xml_find_first(
          xml2::read_html(data_home_sidebar(pkg)),
          ".//div[@class='developers']"
        )
      )
    )
  )
})

test_that("data_home_sidebar() can be removed", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$home$sidebar <- FALSE
  # not built by data_home_sidebar()
  expect_false(data_home_sidebar(pkg))

  # nor later -- so probably not to be tested here?!
  td <- withr::local_tempdir()
  pkg <- as_pkgdown(pkg)
  pkg$dst_path <- td
  build_home_index(pkg)
  html <- xml2::read_html(file.path(td, "index.html"))
  expect_equal(
    length(xml2::xml_children(xml2::xml_find_first(html, ".//div[@id='pkgdown-sidebar']"))),
    0
  )
})


test_that("data_home_sidebar() can be defined by a HTML file", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$home$sidebar$html <- "sidebar.html"
  expect_equal(
    data_home_sidebar(pkg),
    paste0(read_lines(file.path(pkg$src_path, "sidebar.html")), collapse = "\n")
  )
})

test_that("data_home_sidebar() errors well when no HTML file", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$home$sidebar$html <- "file.html"
  expect_snapshot_error(data_home_sidebar(pkg))
})

test_that("data_home_sidebar() can get a custom component", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)

  pkg$meta$home$sidebar <- list(
    structure = c("fancy"),
    components = list(
      fancy = list(
        title = "Fancy section",
        text = "How *cool* is pkgdown?!"
      )
    )
  )

  result <- xml2::read_html(
    data_home_sidebar(pkg)
  )

  expect_snapshot(
    xml2::xml_find_first(result, ".//div[@class='fancy-section']")
  )
})

test_that("data_home_sidebar() can add a README", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)

  pkg$meta$home$sidebar <- list(structure = c("license", "toc"))

  result <- xml2::read_html(
    data_home_sidebar(pkg)
  )

  expect_snapshot(
    xml2::xml_find_first(result, ".//div[@class='table-of-contents']")
  )
})

test_that("data_home_sidebar() outputs informative error messages", {
  # no component definition for a component named in structure
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$home$sidebar <- list(
    structure = c("fancy")
  )
  expect_snapshot_error(data_home_sidebar(pkg))

  # no component definition for two components named in structure
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  pkg$meta$home$sidebar <- list(
    structure = c("fancy", "cool")
  )
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
