context("href")

test_that("can link function calls", {
  old <- cur_topic_index_set(c(foo = "bar"))
  on.exit(cur_topic_index_set(old))

  expect_equal(href_expr_(foo()), "bar.html")
  expect_equal(href_expr_(foo(1, 2, 3)), "bar.html")
})

test_that("respects href_topic_local args", {
  old <- cur_topic_index_set(c(foo = "bar"))
  on.exit(cur_topic_index_set(old))

  expect_equal(href_expr_(foo(), depth = 0), "reference/bar.html")
  expect_equal(href_expr_(foo(), current = "bar"), NULL)
})

test_that("can link remote objects", {
  expect_equal(href_expr_(MASS::abbey), href_topic_remote("abbey", "MASS"))
  expect_equal(href_expr_(MASS::addterm()), href_topic_remote("addterm", "MASS"))
  expect_equal(href_expr_(MASS::addterm.default()), href_topic_remote("addterm", "MASS"))

  # Doesn't exist
  expect_equal(href_expr_(MASS::blah), NULL)
})

test_that("can link to remote pkgdown sites", {
  expect_equal(href_expr_(pkgdown::add_slug), href_topic_remote("pkgdown", "add_slug"))
  expect_equal(href_expr_(pkgdown::add_slug()), href_topic_remote("pkgdown", "add_slug"))
})

test_that("warns if topic not found", {
  old <- cur_topic_index_set(c(foo = "bar"))
  on.exit(cur_topic_index_set(old))

  expect_warning(x <- href_expr(quote(blah())), "Failed to find topic")
  expect_null(x)
})

test_that("only links bare symbols if requested", {
  old <- cur_topic_index_set(c(foo = "bar"))
  on.exit(cur_topic_index_set(old))

  expect_equal(href_expr_(foo), NULL)
  expect_equal(href_expr_(foo, bare_symbol = TRUE), "bar.html")
})

test_that("can link ? calls", {
  old <- cur_topic_index_set(c(foo = "foo", "foo-package" = "foo-package"))
  on.exit(cur_topic_index_set(old))

  expect_equal(href_expr_(?foo), "foo.html")
  expect_equal(href_expr_(?"foo"), "foo.html")
  expect_equal(href_expr_(package?foo), "foo-package.html")
})

test_that("can link to vignette", {
  expect_equal(href_expr_(vignette("x"), depth = 0), "articles/x.html")

  # But not (currently) if package supplied
  expect_null(href_expr_(vignette('x', package = 'y')))
})
