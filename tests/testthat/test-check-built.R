test_that("check images in readme", {
  pkg <- local_pkgdown_site()
  pkg <- pkg_add_file(pkg, "README.md", "![foo](vignettes/kitten.jpg)")
  suppressMessages(build_home_index(pkg))

  # no image, so should warn
  expect_snapshot(check_built_site(pkg))

  # create and build vignette that uses image, so no warning
  pkg <- pkg_add_file(pkg, "vignettes/kitten.Rmd", "![foo](kitten.jpg)")
  pkg <- pkg_add_kitten(pkg, "vignettes")

  suppressMessages(build_article("kitten", pkg))
  suppressMessages(expect_no_warning(check_built_site(pkg)))
})
