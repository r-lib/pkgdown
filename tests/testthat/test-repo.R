#  repo_auto_link ---------------------------------------------------------

test_that("authors are automatically linked", {
  pkg <- list(repo = repo_meta(user = "TEST/"))

  # email addresses shouldn't get linked
  expect_equal(repo_auto_link(pkg, "x@y.com"), "x@y.com")

  # must have leading whitespace or open parens
  expect_equal(repo_auto_link(pkg, "@y"), "<a href='TEST/y'>@y</a>")
  expect_equal(repo_auto_link(pkg, " @y"), " <a href='TEST/y'>@y</a>")
  expect_equal(repo_auto_link(pkg, "(@y)"), "(<a href='TEST/y'>@y</a>)")
})

test_that("issues are automatically linked", {
  pkg <- list(repo = repo_meta(issue = "TEST/"))
  expect_equal(repo_auto_link(pkg, "#123"), "<a href='TEST/123'>#123</a>")
})

# repo_source -------------------------------------------------------------

test_that("repo_source() truncates automatically", {
  pkg <- list(repo = repo_meta("https://github.com/r-lib/pkgdown/blob/master"))

  verify_output(test_path("test-repo-source.txt"), {
    cat(repo_source(pkg, character()))
    cat(repo_source(pkg, "a"))
    cat(repo_source(pkg, letters[1:10]))
  })
})


# package_repo ------------------------------------------------------------

test_that("can find github from BugReports or URL", {
  ref <- repo_meta(
    "https://github.com/r-lib/pkgdown/blob/master/",
    "https://github.com/r-lib/pkgdown/issues/",
    "https://github.com/"
  )

  # BugReports beats URL
  desc <- desc::desc(text = c(
    "URL: https://github.com/r-lib/BLAHBLAH",
    "BugReports: https://github.com/r-lib/pkgdown/issues"
  ))
  expect_equal(package_repo(desc, list()), ref)

  desc <- desc::desc(text = c(
    "URL: https://github.com/r-lib/pkgdown"
  ))
  expect_equal(package_repo(desc, list()), ref)

  # Url can be in any position
  desc <- desc::desc(text = c(
    "URL: https://pkgdown.r-lib.org, https://github.com/r-lib/pkgdown")
  )
  expect_equal(package_repo(desc, list()), ref)
})

test_that("meta overrides autodetection", {
  ref <- repo_meta("https://github.com/r-lib/pkgdown/blob/master/")
  desc <- desc::desc(text = "URL: https://github.com/r-lib/pkgdown")
  expect_equal(package_repo(desc, list(repo = ref)), ref)
})

test_that("returns NULL if no urls found", {
  desc <- desc::desc(text = "URL: https://pkgdown.r-lib.org")
  expect_equal(package_repo(desc, list()), NULL)
})
