test_that("check_bootswatch_theme() works", {
  pkg <- as_pkgdown(test_path("assets/reference"))
  expect_equal(check_bootswatch_theme("_default", 4, pkg), NULL)
  expect_equal(check_bootswatch_theme("lux", 4, pkg), "lux")
  expect_snapshot_error(check_bootswatch_theme("paper", 4, pkg))
})

test_that("capture data_template()", {
  pkg <- as_pkgdown(test_path("assets/site-empty"))
  data <- data_template(pkg)
  data$year <- "<year>"
  data$footer$right <- gsub(packageVersion("pkgdown"), "{version}", data$footer$right, fixed = TRUE)
  expect_snapshot_output(data)
})

test_that("can include text in header, before body, and after body", {
  local_edition(3)
  pkg <- local_pkgdown_site(test_path("assets/site-empty"), '
    template:
      includes:
        in_header: <test>in header</test>
        before_body: <test>before body</test>
        after_body: <test>after body</test>
  ')

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
  expect_message(init_site(pkg))
  html <- render_page_html(pkg, "title-body")
  expect_equal(
    xpath_text(html, ".//test"),
    c("in header", "before body", "after body")
  )
})
