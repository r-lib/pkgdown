test_that("data_home_sidebar() works by default", {
  pkg <- test_path("assets/sidebar")
  pkg <- as_pkgdown(pkg)
  expect_snapshot(cat(data_home_sidebar(pkg)))
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
        text = "How cool is pkgdown?!"
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
    components = list(fancy = list(html = "bla"))
  )
  expect_snapshot_error(data_home_sidebar(pkg))

  # no title nor html

  pkg$meta$home$sidebar <- list(
    structure = c("fancy"),
    components = list(fancy = list(html = "bla"))
  )
  expect_snapshot_error(data_home_sidebar(pkg))
})
