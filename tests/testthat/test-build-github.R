test_that("a CNAME record is built if a url exists in metadata", {
  pkg <- local_pkgdown_site(test_path("assets/cname"))

  dir_create(path(pkg$dst_path, "docs"))
  expect_snapshot(build_github_pages(pkg))
  expect_equal(read_lines(path(pkg$dst_path, "CNAME")), "testpackage.r-lib.org")
})

test_that("CNAME URLs are valid", {
  expect_equal(cname_url("http://google.com/"), "google.com")
  expect_equal(cname_url("https://google.com/"), "google.com")

  # this is not a valid URL because it has a trailing path
  expect_null(cname_url("http://google.com/path/"))
})
