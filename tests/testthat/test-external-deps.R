test_that("check integrity validates integrity", {
  temp <- withr::local_tempfile(lines = letters)

  expect_snapshot(error = TRUE, {
    check_integrity(temp, "sha123-abc")
    check_integrity(temp, "sha256-abc")
  })

  integrity <- paste0("sha256-", compute_hash(temp, 256L))
  expect_no_error(check_integrity(temp, integrity))
})

test_that("can parse integrity", {
  expect_equal(parse_integrity("sha256-abc"), list(size = 256L, hash = "abc"))
})
