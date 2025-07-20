test_that("checks its inputs", {
  pkg <- local_pkgdown_site()

  expect_snapshot(error = TRUE, {
    preview_site(pkg, path = 1)
    preview_site(pkg, path = "foo")
    preview_site(pkg, preview = 1)
  })
})

test_that("local_path adds index.html if needed", {
  pkg <- local_pkgdown_site()
  file_create(path(pkg$dst_path, "test.html"))
  expect_equal(
    local_path(pkg, "test.html"),
    path(pkg$dst_path, "test.html")
  )

  dir_create(path(pkg$dst_path, "reference"))
  expect_equal(
    local_path(pkg, "reference"),
    path(pkg$dst_path, "reference", "index.html")
  )
})
