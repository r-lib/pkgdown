test_that("capture data_template()", {
  pkg <- local_pkgdown_site()
  data <- data_template(pkg)
  data$year <- "<year>"
  data$footer$right <- gsub(
    packageVersion("pkgdown"),
    "{version}",
    data$footer$right,
    fixed = TRUE
  )
  expect_snapshot_output(data)
})

test_that("can include text in header, before body, and after body", {
  pkg <- local_pkgdown_site(
    meta = list(
      template = list(
        includes = list(
          in_header = "<test>in header</test>",
          before_body = "<test>before body</test>",
          after_body = "<test>after body</test>"
        )
      )
    )
  )

  expect_named(
    data_template(pkg)$includes,
    c("in_header", "before_body", "after_body")
  )

  pkg$bs_version <- 3
  html <- render_page_html(pkg, "title-body")
  expect_equal(
    xpath_text(html, ".//test"),
    c("in header", "before body", "after body")
  )

  pkg$bs_version <- 5
  suppressMessages(init_site(pkg))
  html <- render_page_html(pkg, "title-body")
  expect_equal(
    xpath_text(html, ".//test"),
    c("in header", "before body", "after body")
  )
})

test_that("check_opengraph validates inputs", {
  data_open_graph_ <- function(x) {
    pkg <- local_pkgdown_site(meta = list(template = list(opengraph = x)))
    data_open_graph(pkg)
    invisible()
  }

  expect_snapshot(error = TRUE, {
    data_open_graph_(list(foo = list()))
    data_open_graph_(list(foo = list(), bar = list()))
    data_open_graph_(list(twitter = 1))
    data_open_graph_(list(twitter = list()))
    data_open_graph_(list(image = 1))
  })
})
