test_that("can generate three types of row", {
  ref <- list(
    list(title = "A"),
    list(subtitle = "B"),
    list(contents = c("a", "b", "c", "?"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)

  verify_output(test_path("test-build-reference-index.txt"), {
    data_reference_index(pkg)
  })
})

test_that("warns if missing topics", {
  ref <- list(
    list(contents = c("a", "b"))
  )
  meta <- list(reference = ref)
  pkg <- as_pkgdown(test_path("assets/reference"), override = meta)
  withr::local_envvar(new = c(CI = "false"))
  expect_warning(data_reference_index(pkg), "Topics missing")
  withr::local_envvar(new = c(CI = "true"))
  expect_error(data_reference_index(pkg), "Topics missing")
})

test_that("default reference includes all functions", {
  ref <- default_reference_index(test_path("assets/reference"))
  expect_equal(ref[[1]]$contents, paste0("`", c(letters[1:3], "?"), "`"))
})
