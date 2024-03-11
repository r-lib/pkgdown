test_that("check_bslib_theme() works", {
  pkg <- as_pkgdown(test_path("assets/reference"))
  expect_equal(check_bslib_theme("_default", pkg, bs_version = 4), "default")
  expect_equal(check_bslib_theme("lux", pkg, bs_version = 4), "lux")
  expect_snapshot_error(check_bslib_theme("paper", pkg, bs_version = 4))
  expect_snapshot_error(check_bslib_theme("paper", pkg, bs_version = 4, field = c("template", "preset")))
})

test_that("get_bslib_theme() works with template.bslib.preset", {
  pkg <- local_pkgdown_site(test_path("assets/site-empty"), '
    template:
      bootstrap: 5
      bslib:
        preset: shiny
        enable-shadows: true
  ')

  expect_equal(get_bslib_theme(pkg), "shiny")
  expect_no_error(bs_theme(pkg))

  pkg <- local_pkgdown_site(test_path("assets/site-empty"), '
    template:
      bootstrap: 5
      bslib:
        preset: lux
        enable-shadows: true
  ')

  expect_equal(get_bslib_theme(pkg), "lux")
  expect_no_error(bs_theme(pkg))
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
