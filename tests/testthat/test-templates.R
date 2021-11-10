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

test_that("find templates in local pkgdown first", {
  pkg <- local_pkgdown_site(test_path("assets", "templates-local"))

  # local template used over default pkgdown template
  expect_equal(
    find_template("content", "article", templates_dir = templates_dir(pkg), src_path = pkg$src_path),
    path(pkg$src_path, "pkgdown", "templates", "content-article.html")
  )

  expect_equal(
    find_template("footer", "article", templates_dir = templates_dir(pkg), src_path = pkg$src_path),
    path(pkg$src_path, "pkgdown", "templates", "footer-article.html")
  )

  # pkgdown template used (no local template)
  expect_equal(
    find_template("content", "tutorial", templates_dir = templates_dir(pkg), src_path = pkg$src_path),
    path_pkgdown("BS3", "templates", "content-tutorial.html")
  )

  expect_equal(
    find_template("footer", "ignored", templates_dir = templates_dir(pkg), src_path = pkg$src_path),
    path_pkgdown("BS3", "templates", "footer.html")
  )
})
