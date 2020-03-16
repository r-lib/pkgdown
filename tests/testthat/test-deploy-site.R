# ci_commit_sha() ------------------------------------------------------------

test_that("commit sha is retrieved TravisCI env variable", {

  commit_id = "fc1a99f7fd0f311144a40d23170b2c9035ef5b44"

  withr::local_envvar(list("TRAVIS_COMMIT" = commit_id))
  expect_equal(ci_commit_sha(), commit_id)
})

test_that("commit sha is retrieved GitHub Actions env variable", {

  commit_id = "def1d0b936aecad748ee3973fd4280648bf284fe"

  withr::local_envvar(list("GITHUB_SHA" = commit_id))
  expect_equal(ci_commit_sha(), commit_id)
})

test_that("commit sha not found gives empty string", {
  expect_equal(ci_commit_sha(), "")
})

