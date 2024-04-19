test_that("pkgdown_field produces useful description", {
  local_edition(3)

  pkg <- local_pkgdown_site()
  file_touch(file.path(pkg$src_path, "_pkgdown.yml"))

  expect_equal(pkgdown_field(pkg, c("a", "b")), "a.b")
  expect_equal(pkgdown_field(pkg, c("a", "b"), fmt = TRUE), "{.field a.b}")
  expect_equal(pkgdown_field(pkg, c("a"), cfg = TRUE), "a in _pkgdown.yml")
  expect_snapshot(
    cli::cli_inform(pkgdown_field(pkg, c("a"), cfg = TRUE, fmt = TRUE))
  )

  expect_snapshot(error = TRUE, {
    check_yaml_has("x", where = "a", pkg = pkg)
    check_yaml_has(c("x", "y"), where = "a", pkg = pkg)
  })
})
