test_that("works by default", {
  pkg <- structure(
    list(
      desc = desc::desc(text = "Authors@R: person('First', 'Last', role = 'cre')")
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

