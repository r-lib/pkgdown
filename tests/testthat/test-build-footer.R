test_that("works by default", {
  pkg <- structure(
    list(
      desc = desc::desc(text = "Authors@R: person('First', 'Last', role = 'cre')"),
      src_path = tempdir()
    ),
    class = "pkgdown"
  )
  footer <- data_footer(pkg)
  footer$right <- gsub(packageVersion("pkgdown"), "{version}", footer$right, fixed = TRUE)

  expect_snapshot_output(footer)
})

test_that("includes package component", {
  pkg <- structure(
    list(
      package = "noodlr",
      desc = desc::desc(text = "Authors@R: person('First', 'Last', role = 'cre')"),
      src_path = tempdir(),
      meta = list(
        footer = list(
          structure = list(left = "package")
        )
      )
    ),
    class = "pkgdown"
  )
  expect_equal(data_footer(pkg)$left, "<p>noodlr</p>")
})

test_that("can use custom components", {
  pkg <- structure(list(
    desc = desc::desc(text = "Authors@R: person('a', 'b', roles = 'cre')"),
    src_path = tempdir(),
    meta = list(
      footer = list(
        structure = list(left = "test"),
        components = list(test = "_test_")
      )
    )),
    class = "pkgdown"
  )
  expect_equal(data_footer(pkg)$left, "<p><em>test</em></p>")
})

test_that("multiple components are pasted together", {
  pkg <- structure(list(
    desc = desc::desc(text = "Authors@R: person('a', 'b', roles = 'cre')"),
    src_path = tempdir(),
    meta = list(
      footer = list(
        structure = list(left = c("a", "b")),
        components = list(a = "a", b = "b")
      )
    )),
    class = "pkgdown"
  )
  expect_equal(data_footer(pkg)$left, "<p>a b</p>")
})

test_that("validates meta components", {
  data_footer_ <- function(...) {
    pkg <- local_pkgdown_site(meta = list(...))
    data_footer(pkg)
  }

  expect_snapshot(error = TRUE, {
    data_footer_(footer = 1)
    data_footer_(footer = list(structure = 1))
    data_footer_(footer = list(components = 1))
    data_footer_(authors = list(footer = list(roles = 1)))
    data_footer_(authors = list(footer = list(text = 1)))
  })
})