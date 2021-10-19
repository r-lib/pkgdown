test_that("template_candidates look for specific first", {
  expect_equal(
    path_file(template_candidates("content", "article")),
    c("content-article.html", "content.html")
  )
})

test_that("template_candidates look in bs template, template dir, then pkgdown", {
  paths <- template_candidates("content", "article", templates_dir = "/test")
  dirs <- unique(path_dir(paths))

  expect_equal(dirs, c("/test/BS3", "/test", path_pkgdown("templates", "BS3")))
})
