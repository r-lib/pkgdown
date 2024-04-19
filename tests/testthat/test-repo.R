#  repo_auto_link ---------------------------------------------------------

test_that("authors are automatically linked", {
  pkg <- list(repo = repo_meta(user = "TEST/"))

  # email addresses shouldn't get linked
  expect_equal(repo_auto_link(pkg, "x@y.com"), "x@y.com")

  # must have leading whitespace or open parens
  expect_equal(repo_auto_link(pkg, "@y"), "<a href='TEST/y'>@y</a>")
  expect_equal(repo_auto_link(pkg, " @y"), " <a href='TEST/y'>@y</a>")
  expect_equal(repo_auto_link(pkg, "(@y)"), "(<a href='TEST/y'>@y</a>)")

  expect_equal(repo_auto_link(pkg, "<p>@y some other text.</p>"), "<p><a href='TEST/y'>@y</a> some other text.</p>")
})

test_that("issues are automatically linked", {
  pkg <- list(repo = repo_meta(issue = "TEST/"))
  expect_equal(repo_auto_link(pkg, "(#123"), "(<a href='TEST/123'>#123</a>")
  expect_equal(repo_auto_link(pkg, "in #123"), "in <a href='TEST/123'>#123</a>")
  expect_equal(repo_auto_link(pkg, "<p>#123 some other text.</p>"), "<p><a href='TEST/123'>#123</a> some other text.</p>")
  expect_equal(repo_auto_link(pkg, "<p><a href='TEST/123/'>#123</a></p>"), "<p><a href='TEST/123/'>#123</a></p>")
})

test_that("already linked issues aren't re-linked", {
  pkg <- list(repo = repo_meta(issue = "TEST/"))
  expect_equal(repo_auto_link(pkg, "<p><a href='NOT/ABC/'>#123</a></p>"), "<p><a href='NOT/ABC/'>#123</a></p>")
})

test_that("URLs with hash (#) are preserved", {
  pkg <- list(repo = repo_meta(issue = "TEST/"))
  expect_equal(
    repo_auto_link(pkg, "[example 5.4](https:/my.site#5-4-ad)"),
    "[example 5.4](https:/my.site#5-4-ad)"
  )
})

test_that("Jira issues are automatically linked", {
  pkg <- list(repo = repo_meta(issue = "TEST/"))
  pkg$repo$jira_projects <- c("JIRA", "OTHER")
  expect_equal(repo_auto_link(pkg, "JIRA-123"), "<a href='TEST/JIRA-123'>JIRA-123</a>")
  expect_equal(repo_auto_link(pkg, "OTHER-4321"), "<a href='TEST/OTHER-4321'>OTHER-4321</a>")
  # but only the jira projects specified are caught
  expect_equal(repo_auto_link(pkg, "NOPE-123"), "NOPE-123")
})

# repo_source -------------------------------------------------------------

test_that("repo_source() truncates automatically", {
  pkg <- list(repo = repo_meta_gh_like("https://github.com/r-lib/pkgdown"))

  expect_snapshot({
    cat(repo_source(pkg, character()))
    cat(repo_source(pkg, "a"))
    cat(repo_source(pkg, letters[1:10]))
  })
})

# repo_source with alternate default branch -------------------------------

test_that("repo_source() uses the branch setting in meta", {
  desc <- desc::desc(text = c("URL: https://github.com/r-lib/pkgdown"))
  pkg <- list(repo = package_repo(desc, list(repo = list(branch = "main"))))

  expect_match(
    repo_source(pkg, "a"),
    "https://github.com/r-lib/pkgdown/blob/main/a"
  )
})

# package_repo ------------------------------------------------------------

test_that("can find github from BugReports or URL", {
  ref <- repo_meta_gh_like("https://github.com/r-lib/pkgdown")

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

  # URL can be in any position
  desc <- desc::desc(text = c(
    "URL: https://pkgdown.r-lib.org, https://github.com/r-lib/pkgdown")
  )
  expect_equal(package_repo(desc, list()), ref)
})

test_that("can find gitlab url", {
  ref <- repo_meta_gh_like("https://gitlab.com/msberends/AMR")
  desc <- desc::desc(text = c(
    "BugReports: https://gitlab.com/msberends/AMR"
  ))
  expect_equal(package_repo(desc, list()), ref)
})

test_that("GitLab subgroups are properly parsed", {
  issue_url <- function(text) {
    package_repo(desc::desc(text = text), list())$url$issue
  }
  target <- "https://gitlab.com/salim_b/r/pkgs/pal/issues/"
  # 1) from URL field, with and without trailing slash
  expect_equal(
    issue_url("URL: https://gitlab.com/salim_b/r/pkgs/pal/"),
    target
  )
  expect_equal(
    issue_url("URL: https://gitlab.com/salim_b/r/pkgs/pal"),
    target
  )
  # 2) from BugReports field, with and without trailing slash
  expect_equal(
    issue_url("BugReports: https://gitlab.com/salim_b/r/pkgs/pal/issues/"),
    target
  )
  expect_equal(
    issue_url("BugReports: https://gitlab.com/salim_b/r/pkgs/pal/issues"),
    target
  )
  # 3) from URL + BugReports
  expect_equal(
    issue_url(paste0(
      "URL: https://gitlab.com/salim_b/r/pkgs/pal\n",
      "BugReports: https://gitlab.com/salim_b/r/pkgs/pal/issues/"
    )),
    target
  )
})

test_that("can find github enterprise url", {
  ref <- repo_meta_gh_like("https://github.acme.com/roadrunner/speed")
  desc <- desc::desc(text = c(
    "BugReports: https://github.acme.com/roadrunner/speed"
  ))
  expect_equal(package_repo(desc, list()), ref)
})

test_that("meta overrides autodetection", {
  ref <- repo_meta("https://github.com/r-lib/pkgdown/blob/main/")
  desc <- desc::desc(text = "URL: https://github.com/r-lib/pkgdown")
  expect_equal(package_repo(desc, list(repo = ref)), ref)
})

test_that("returns NULL if no urls found", {
  desc <- desc::desc(text = "URL: https://pkgdown.r-lib.org")
  expect_equal(package_repo(desc, list()), NULL)
})

test_that("repo_type detects repo type", {
  repo_type2 <- function(url) {
   repo_type(list(repo = list(url = list(home = url))))
  }

  expect_equal(repo_type2("https://github.com/r-lib/pkgdown"), "github")
  expect_equal(repo_type2("https://github.r-lib.com/pkgdown"), "github")
  expect_equal(repo_type2("https://gitlab.com/r-lib/pkgdown"), "gitlab")
  expect_equal(repo_type2("https://gitlab.r-lib.com/pkgdown"), "gitlab")
  expect_equal(repo_type2(NULL), "other")
})
