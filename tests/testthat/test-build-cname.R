context("build_cname")

test_that("a CNAME record is built if a url exists in metadata", {
  cname <- test_path("assets/cname")
  dir_create(path(cname, "docs"))

  on.exit({
    clean_site(cname)
    file_delete(path(cname, "docs", "CNAME"))
  })

  expect_output(build_cname(cname))
  expect_equal(read_lines(path(cname, "docs", "CNAME")), "testpackage.r-lib.org")
})
