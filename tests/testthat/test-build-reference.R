test_that("parse failures include file name", {
  pkg <- local_pkgdown_site(test_path("assets/reference-fail"))
  expect_snapshot(build_reference(pkg), error = TRUE)
})

test_that("examples_env runs pre and post code", {
  dst_path <- withr::local_tempdir()
  dir_create(path(dst_path, "reference"))

  pkg <- list(
    package = "test",
    src_path = test_path("assets/reference-pre-post"),
    dst_path = dst_path
  )

  env <- local(examples_env(pkg))
  expect_equal(env$a, 2)
})

test_that("examples_env sets width", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(code = list(width = 50))
  )
  dir_create(path(pkg$dst_path, "reference"))

  examples_env(pkg)
  expect_equal(getOption("width"), 50)
})

test_that("test usage ok on rendered page", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(template = list(bootstrap = 3))
  )
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "c"))

  html <- xml2::read_html(path(pkg$dst_path, "reference", "c.html"))
  expect_equal(xpath_text(html, "//div[@id='ref-usage']", trim = TRUE), "c()")
  clean_site(pkg, quiet = TRUE)

  pkg <- local_pkgdown_site(test_path("assets/reference"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "c"))
  html <- xml2::read_html(path(pkg$dst_path, "reference", "c.html"))
  # tweak_anchors() moves id into <h2>
  expect_equal(xpath_text(html, "//div[h2[@id='ref-usage']]/div", trim = TRUE), "c()")
})

test_that(".Rd without usage doesn't get Usage section", {
  pkg <- local_pkgdown_site(
    test_path("assets/reference"),
    list(template = list(bootstrap = 3))
  )
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "e"))

  html <- xml2::read_html(path(pkg$dst_path, "reference", "e.html"))
  expect_equal(xpath_length(html, "//div[@id='ref-usage']"), 0)
  clean_site(pkg, quiet = TRUE)

  pkg <- local_pkgdown_site(test_path("assets/reference"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "e"))
  html <- xml2::read_html(path(pkg$dst_path, "reference", "e.html"))
  # tweak_anchors() moves id into <h2>
  expect_equal(xpath_length(html, "//div[h2[@id='ref-usage']]"), 0)
})

test_that("pkgdown html dependencies are suppressed from examples in references", {
  pkg <- local_pkgdown_site(test_path("assets/reference-html-dep"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "a"))
  html <- xml2::read_html(path(pkg$dst_path, "reference", "a.html"))

  # jquery is only loaded once, even though it's included by an example
  expect_equal(xpath_length(html, ".//script[(@src and contains(@src, '/jquery'))]"), 1)

  # same for bootstrap js and css
  str_subset_bootstrap <- function(x) {
    bs_rgx <- "bootstrap-[\\d.]+" # ex: bootstrap-5.1.0 not bootstrap-toc,
    grep(bs_rgx, x, value = TRUE, perl = TRUE)
  }
  bs_js_src <- str_subset_bootstrap(
    xpath_attr(html, ".//script[(@src and contains(@src, '/bootstrap'))]", "src")
  )
  expect_length(bs_js_src, 1)

  bs_css_href <- str_subset_bootstrap(
    xpath_attr(html, ".//link[(@href and contains(@href, '/bootstrap'))]", "href")
  )
  expect_length(bs_css_href, 1)
})

test_that("examples are reproducible by default, i.e. 'seed' is respected", {
  pkg <- local_pkgdown_site(test_path("assets/reference"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "f"))

  html <- xml2::read_html(path(pkg$dst_path, "reference", "f.html"))
  examples <- xpath_text(html, ".//code//*[contains(@class, 'r-out')]")

  expect_snapshot(cat(examples))
})

test_that("arguments get individual ids", {
  pkg <- local_pkgdown_site(test_path("assets/reference"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "a"))

  html <- xml2::read_html(path(pkg$dst_path, "reference", "a.html"))
  expect_equal(xpath_attr(html, "//dt", "id"), c("arg-a", "arg-b", "arg-c"))

})

test_that("title and page title escapes html", {
  pkg <- local_pkgdown_site(test_path("assets/reference"))
  suppressMessages(init_site(pkg))
  suppressMessages(build_reference(pkg, topics = "g"))

  html <- xml2::read_html(path(pkg$dst_path, "reference", "g.html"))
  expect_equal(xpath_text(html, "//title", trim = TRUE), "g <-> h — g • testpackage")
  expect_equal(xpath_text(html, "//h1", trim = TRUE), "g <-> h")
})

test_that("get_rdname handles edge cases", {
  expect_equal(get_rdname(list(file_in = "foo..Rd")), "foo.")
  expect_equal(get_rdname(list(file_in = "foo.rd")), "foo")
})
