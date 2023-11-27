test_that("pkgdown_field(s) produces useful description", {
  local_edition(3)

  pkg <- local_pkgdown_site()
  file_touch(file.path(pkg$src_path, "_pkgdown.yml"))

  expect_snapshot({
    pkgdown_field(c("a", "b"))
  })

  expect_snapshot(error = TRUE, {
    check_yaml_has("x", where = "a", pkg = pkg)
    check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
  })
})
