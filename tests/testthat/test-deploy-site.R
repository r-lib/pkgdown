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
