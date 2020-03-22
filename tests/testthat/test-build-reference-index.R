test_that("can generate three types of row", {
  ref <- list(
    list(title = "A"),
    list(subtitle = "B"),
    list(contents = c("a", "b", "c"))
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
  expect_warning(data_reference_index(pkg), "Topics missing")
})

test_that("default reference includes all functions", {
  ref <- default_reference_index(test_path("assets/reference"))
  expect_equal(ref[[1]]$contents, paste0("`", letters[1:3], "`"))
})
