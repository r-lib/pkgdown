test_that("both versions of build_site have same arguments", {
  expect_equal(formals(build_site_local), formals(build_site_external))
})

test_that("build_site can be made unquiet", {
  pkg <- local_pkgdown_site(test_path("assets/articles-images"))
  expect_snapshot(
    build_site(pkg, quiet = FALSE),
    transform = function(x) {
      # First replace path without affecting newlines
      x <- gsub(pkg$src_path, "<src_path>", x, fixed = TRUE)

      # For the destination path, be careful to preserve structure
      # Look for "Writing to:" followed by newline and any characters
      x <- gsub(
        "Writing to:\\n([^\\n]+)",
        "Writing to:\\n<dst_path>",
        x
      )

      # Also handle any inline paths
      x <- gsub(pkg$dst_path, "<dst_path>", x, fixed = TRUE)

      return(x)
    }
  )
})
