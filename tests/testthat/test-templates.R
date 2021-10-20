test_that("template_candidates look for specific first", {
  expect_equal(
    path_file(template_candidates("content", "article")),
    c("content-article.html", "content.html")
  )
})

test_that("template_candidates look in template dir then pkgdown", {
  paths <- template_candidates("content", "article", templates_dir = "/test")
  dirs <- unique(path_dir(paths))
  expect_equal(dirs, c("/test", path_pkgdown("BS3", "templates")))
})


test_that("look for templates_dir in right places", {
  dir <- withr::local_tempdir()
  pkg <- list(src_path = dir, meta = list(template = list()))

  # Look in site templates
  expect_equal(templates_dir(pkg), path(dir, "pkgdown", "templates"))

  # Look in specified directory
  pkg$meta$template$path <- path(withr::local_tempdir())
  expect_equal(templates_dir(pkg), pkg$meta$template$path)
})
