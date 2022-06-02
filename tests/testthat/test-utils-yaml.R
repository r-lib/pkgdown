test_that("pkgdown_field(s) produces useful description", {
  pkg <- local_pkgdown_site()
  file_touch(file.path(pkg$src_path, "_pkgdown.yml"))

  expect_snapshot({
    pkgdown_field(pkg, c("a", "b"))
    pkgdown_fields(pkg, list(c("a", "b"), "c"))
  })
})

test_that("pkgdown_field(s) produces useful description", {
  pkg <- local_pkgdown_site()
  file_touch(file.path(pkg$src_path, "_pkgdown.yml"))

  expect_snapshot(error = TRUE, {
    check_yaml_has("x", where = "a", pkg = pkg)
    check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
  })
})
