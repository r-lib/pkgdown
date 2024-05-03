test_that("config_field produces useful description", {
  pkg <- local_pkgdown_site()
  file_touch(file.path(pkg$src_path, "_pkgdown.yml"))

  expect_equal(config_field(c("a", "b")), "a.b")
  expect_equal(config_field(c("a", "b"), fmt = TRUE), "{.field a.b}")

  expect_snapshot(error = TRUE, {
    check_yaml_has("x", where = "a", pkg = pkg)
    check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
  })
})
