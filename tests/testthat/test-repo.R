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
  withr::local_envvar(GITHUB_HEAD_REF = "HEAD")
  pkg <- list(repo = repo_meta_gh_like("https://github.com/r-lib/pkgdown"))

  expect_snapshot({
    cat(repo_source(pkg, character()))
    cat(repo_source(pkg, "a"))
    cat(repo_source(pkg, letters[1:10]))
  })
})

test_that("repo_source() is robust to trailing slash", {
  pkg <- list(repo = repo_meta_gh_like("https://github.com/r-lib/pkgdown"))

  meta <- function(x) {
    list(repo = list(url = list(source = x)))
  }
  source <- "Source: <a href='http://example.com/a'><code>a</code></a>"
  expect_equal(repo_source(meta("http://example.com"), "a"), source)
  expect_equal(repo_source(meta("http://example.com/"), "a"), source)
})

test_that("repo_source() uses the branch setting in meta", {
  pkg <- local_pkgdown_site(
    meta = list(repo = list(branch = "main")),
    desc = list(URL = "https://github.com/r-lib/pkgdown")
  )
  expect_match(
    repo_source(pkg, "a"),
    "https://github.com/r-lib/pkgdown/blob/main/a"
  )
})

# package_repo ------------------------------------------------------------

test_that("can find github from BugReports or URL", {
  withr::local_envvar(GITHUB_HEAD_REF = "HEAD")
  expected <- repo_meta_gh_like("https://github.com/r-lib/pkgdown")

  pkg <- local_pkgdown_site(desc = list(
    URL = "https://github.com/r-lib/pkgdown"
  ))
  expect_equal(package_repo(pkg), expected)

  # BugReports beats URL
  pkg <- local_pkgdown_site(desc = list(
    URL = "https://github.com/r-lib/BLAHBLAH",
    BugReports = "https://github.com/r-lib/pkgdown/issues"
  ))
  expect_equal(package_repo(pkg), expected)

  # URL can be in any position
  pkg <- local_pkgdown_site(desc = list(
    URL = "https://pkgdown.r-lib.org, https://github.com/r-lib/pkgdown"
  ))
  expect_equal(package_repo(pkg), expected)
})

test_that("can find gitlab url", {
  withr::local_envvar(GITHUB_HEAD_REF = "HEAD")
  url <- "https://gitlab.com/msberends/AMR"
  pkg <- local_pkgdown_site(desc = list(URL = url))
  expect_equal(package_repo(pkg), repo_meta_gh_like(url))
})

test_that("uses GITHUB env vars if set", {
  withr::local_envvar(GITHUB_HEAD_REF = NA, GITHUB_REF_NAME = "abc")
  expect_equal(
    repo_meta_gh_like("https://github.com/r-lib/pkgdown")$url$source,
    "https://github.com/r-lib/pkgdown/blob/abc/"
  )

  withr::local_envvar(GITHUB_HEAD_REF = "xyz")
  expect_equal(
    repo_meta_gh_like("https://github.com/r-lib/pkgdown")$url$source,
    "https://github.com/r-lib/pkgdown/blob/xyz/"
  )

})

test_that("GitLab subgroups are properly parsed", {
  issue_url <- function(...) {
    pkg <- local_pkgdown_site(desc = list(...))
    pkg$repo$url$issue
  }

  base <- "https://gitlab.com/salim_b/r/pkgs/pal"
  expected <- paste0(base, "/issues/")
  
  expect_equal(issue_url(URL = base), expected)
  expect_equal(issue_url(URL = paste0(base, "/")), expected)
  expect_equal(issue_url(BugReports = paste0(base, "/issues")), expected)
  expect_equal(issue_url(BugReports = paste0(base, "/issues/")), expected)
})

test_that("can find github enterprise url", {
  withr::local_envvar(GITHUB_HEAD_REF = "HEAD")

  url <- "https://github.acme.com/roadrunner/speed"
  pkg <- local_pkgdown_site(desc = list(BugReports = url))
  expect_equal(package_repo(pkg), repo_meta_gh_like(url))
})

test_that("meta overrides autodetection", {
  pkg <- local_pkgdown_site(
    meta = list(repo = list(url = list(home = "http://one.com"))),
    desc = list(URL = "http://two.com")
  )

  expect_equal(package_repo(pkg)$url$home, "http://one.com")
})

test_that("returns NULL if no urls found", {
  pkg <- local_pkgdown_site(desc = list(URL = "https://pkgdown.r-lib.org"))
  expect_null(package_repo(pkg))
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
