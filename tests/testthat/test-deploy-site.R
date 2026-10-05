# ci_commit_sha() ------------------------------------------------------------

test_that("commit sha can be retrieved from travis or GitHub action env vars", {
  sha <- "XYZ"

  withr::with_envvar(
    c("TRAVIS_COMMIT" = sha, "GITHUB_SHA" = ""),
    expect_equal(ci_commit_sha(), sha)
  )
  withr::with_envvar(
    c("TRAVIS_COMMIT" = "", "GITHUB_SHA" = sha),
    expect_equal(ci_commit_sha(), sha)
  )
  withr::with_envvar(
    c("TRAVIS_COMMIT" = "", "GITHUB_SHA" = ""),
    expect_equal(ci_commit_sha(), "")
  )
})

# deploy_to_branch() ---------------------------------------------------------

test_that("deploy_to_branch() appends subdir to url without mangling the scheme", {
  skip_on_cran()
  skip_if_no_pandoc()
  skip_if_not(nzchar(Sys.which("git")), "git not available")

  remote <- withr::local_tempdir()
  withr::with_dir(remote, system2("git", c("init", "--bare", "--quiet")))

  pkg <- local_pkgdown_site(meta = list(url = "https://example.com/pkg"))
  withr::local_dir(pkg$src_path)
  withr::local_envvar(
    GIT_AUTHOR_NAME = "test",
    GIT_AUTHOR_EMAIL = "test@example.com",
    GIT_COMMITTER_NAME = "test",
    GIT_COMMITTER_EMAIL = "test@example.com"
  )
  system2("git", c("init", "--quiet"))
  system2("git", c("add", "-A"))
  system2("git", c("commit", "--quiet", "-m", shQuote("init")))
  system2("git", c("remote", "add", "origin", shQuote(remote)))

  capture.output(suppressMessages(
    deploy_to_branch(
      pkg$src_path,
      subdir = "v1",
      github_pages = FALSE,
      new_process = FALSE,
      install = FALSE,
      examples = FALSE
    )
  ))

  yml <- system2(
    "git",
    c("--git-dir", shQuote(remote), "show", "gh-pages:v1/pkgdown.yml"),
    stdout = TRUE
  )
  expect_match(
    yml,
    "https://example.com/pkg/v1/reference",
    fixed = TRUE,
    all = FALSE
  )
})
