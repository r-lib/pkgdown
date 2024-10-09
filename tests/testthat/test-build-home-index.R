test_that("messages about reading and writing", {
  pkg <- local_pkgdown_site()

  expect_snapshot({
    build_home_index(pkg)
    build_home_index(pkg)
  })
})

test_that("title and description come from DESCRIPTION by default", {
  pkg <- local_pkgdown_site(desc = list(
    Title = "A test title",
    Description = "A test description."
  ))
  expect_equal(data_home(pkg)$pagetitle, "A test title")
  expect_equal(data_home(pkg)$opengraph$description, "A test description.")

  # but overridden by home
  pkg$meta <- list(home = list(title = "X", description = "Y"))
  expect_equal(data_home(pkg)$pagetitle, "X")
  expect_equal(data_home(pkg)$opengraph$description, "Y")
})

test_that("math is handled", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "README.md", "$1 + 1$")
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
  pkg <- local_pkgdown_site(desc = list(Version = "1.0.0-9000"))
  expect_equal(pkg$version, "1.0.0-9000")

  suppressMessages(build_home_index(pkg))
  index <- read_lines(path(pkg$dst_path, "index.html"))
  expect_match(index, "1.0.0-9000", fixed = TRUE, all = FALSE)
})

test_that("data_home_sidebar() works by default", {
  pkg <- local_pkgdown_site()
  expect_snapshot(cat(data_home_sidebar(pkg)))

  # comments are not included
  pkg <- local_pkgdown_site(desc = list(
    `Authors@R` = 'c(
    person("Hadley", "Wickham", , "hadley@rstudio.com", role = c("aut", "cre")),
    person("RStudio", role = c("cph", "fnd"), comment = c("Thank you!"))
    )'
  ))
  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot_output(xpath_xml(html, ".//div[@class='developers']"))
})

test_that("data_home_sidebar() can be removed", {
  pkg <- local_pkgdown_site(meta = list(home = list(sidebar = FALSE)))
  # not built by data_home_sidebar()
  expect_false(data_home_sidebar(pkg))

  # nor later -- so probably not to be tested here?!
  suppressMessages(build_home_index(pkg))
  html <- xml2::read_html(path(pkg$dst_path, "index.html"))
  expect_equal(xpath_length(html, ".//aside/*"), 0)
})

test_that("data_home_sidebar() can be defined by a HTML file", {
  pkg <- local_pkgdown_site(
    meta = list(home = list(sidebar = list(html = "sidebar.html")))
  )
  expect_snapshot(data_home_sidebar(pkg), error = TRUE)

  pkg <- pkg_add_file(pkg, "sidebar.html", "Hello, world!")
  expect_equal(data_home_sidebar(pkg), "Hello, world!\n")
})

test_that("data_home_sidebar() can get a custom markdown formatted component", {
  pkg <- local_pkgdown_site(meta = list(
    home = list(
      sidebar = list(
        structure = "fancy",
        components = list(
          fancy = list(
            title = "Fancy section",
            text = "How *cool* is pkgdown?!"
          )
        )
      )
    )
  ))
  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot_output(xpath_xml(html, ".//div[@class='fancy-section']"))
})

test_that("data_home_sidebar() can add a TOC", {
  pkg <- local_pkgdown_site(meta = list(
    home = list(sidebar = list(structure = "toc"))
  ))

  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot_output(xpath_xml(html, ".//div[@class='table-of-contents']"))
})

test_that("data_home_sidebar() outputs informative error messages", {
  data_home_sidebar_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(home = list(sidebar = list(...))))
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


test_that("cran_unquote works", {
  expect_equal(
    cran_unquote("'Quoting' is CRAN's thing."),
    "Quoting is CRAN's thing."
  )
})

test_that("allow email in BugReports", {
  # currently desc throws a warning if BugReports is an email
  pkg <- local_pkgdown_site(desc = list(BugReports = "me@tidyverse.com"))
  html <- xml2::read_html(data_home_sidebar(pkg))
  expect_snapshot(xpath_xml(html, ".//li/a"))
})

test_that("ANSI are handled", {
  withr::local_options(cli.num_colors = 256)
  pkg <- local_pkgdown_site()

  pkg <- pkg_add_file(pkg, "index.md", sprintf("prefer %s", cli::col_blue("a")))
  suppressMessages(build_home_index(pkg))

  html <- xml2::read_html(path(pkg$dst_path, "index.html"))
  readme_p <- xml2::xml_find_first(html, ".//main[@id='main']/p")
  expect_equal(xml2::xml_text(readme_p), "prefer \u2029[34ma\u2029[39m")
})
