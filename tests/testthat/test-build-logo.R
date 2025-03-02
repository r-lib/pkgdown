test_that("can handle logo in subdir", {
  src <- withr::local_tempdir()
  dst <- withr::local_tempdir()

  dir_create(path(src, "man", "figures"))
  file_create(path(src, "man", "figures", "logo.svg"))
  pkg <- structure(list(src_path = src, dst_path = dst), class = "pkgdown")
  expect_true(has_logo(pkg))

  suppressMessages(copy_logo(pkg))
  expect_true(file_exists(path(dst, "logo.svg")))

  expect_equal(logo_path(pkg, 0), "logo.svg")
  expect_equal(logo_path(pkg, 1), "../logo.svg")
})
