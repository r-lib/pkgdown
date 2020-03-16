# ci_commit_sha() ------------------------------------------------------------

test_that("commit sha is retrieved TravisCI env variable", {

  commit_id = "fc1a99f7fd0f311144a40d23170b2c9035ef5b44"

  withr::with_envvar(
    c("TRAVIS_COMMIT" = commit_id,
      "GITHUB_SHA" = ""),{
      expect_equal(ci_commit_sha(), commit_id)
  })

})

test_that("commit sha is retrieved GitHub Actions env variable", {

  commit_id = "def1d0b936aecad748ee3973fd4280648bf284fe"

  withr::with_envvar(
    c("TRAVIS_COMMIT" = "",
      "GITHUB_SHA" = commit_id),{
        expect_equal(ci_commit_sha(), commit_id)
      })
})

test_that("commit sha not found gives empty string", {
  skip_on_travis()
  skip_if(identical(Sys.getenv("GITHUB_ACTIONS"), "true"))

  expect_equal(ci_commit_sha(), "")
})

