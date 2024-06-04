test_that("check images in readme", {
  pkg <- local_pkgdown_site()
  write_lines("![foo](vignettes/kitten.jpg)", path(pkg$src_path, "README.md"))
  suppressMessages(build_home_index(pkg))

  # no image, so should warn
  expect_snapshot(check_built_site(pkg))

  # create and build vignette that uses image, so no warning
  file_copy(test_path("assets/kitten.jpg"), path(pkg$src_path, "vignettes"))  
  write_lines("![foo](kitten.jpg)", path(pkg$src_path, "vignettes", "kitten.Rmd"))
  pkg <- update_vignettes(pkg)
  suppressMessages(build_article("kitten", pkg))
  suppressMessages(expect_no_warning(check_built_site(pkg)))
})
