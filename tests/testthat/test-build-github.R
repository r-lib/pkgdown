test_that("a CNAME record is built if a url exists in metadata", {
  cname <- test_path("assets/cname")
  dir_create(path(cname, "docs"))

  on.exit({
    clean_site(cname)
    file_delete(path(cname, "docs", "CNAME"))
    file_delete(path(cname, "docs", ".nojekyll"))
  })

  expect_output(build_github_pages(cname))
  expect_equal(read_lines(path(cname, "docs", "CNAME")), "testpackage.r-lib.org")
})

test_that("CNAME URLs are valid", {
  expect_equal(cname_url("http://google.com/"), "google.com")
  expect_equal(cname_url("https://google.com/"), "google.com")

  # this is not a valid URL because it has a trailing path
  expect_null(cname_url("http://google.com/path/"))
})
