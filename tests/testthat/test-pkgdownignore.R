test_that("read_pkgdownignore returns empty when no file exists", {
  pkg <- local_pkgdown_site()
  expect_equal(read_pkgdownignore(pkg$src_path), character())
})

test_that("read_pkgdownignore reads from package root", {
  pkg <- local_pkgdown_site()
  writeLines(c("CLAUDE.md", "AGENTS.md"), path(pkg$src_path, ".pkgdownignore"))

  result <- read_pkgdownignore(pkg$src_path)
  expect_equal(result, c("CLAUDE.md", "AGENTS.md"))
})

test_that("read_pkgdownignore reads from pkgdown/ directory", {
  pkg <- local_pkgdown_site()
  dir_create(path(pkg$src_path, "pkgdown"))
  writeLines("INTERNAL.md", path(pkg$src_path, "pkgdown", ".pkgdownignore"))

  result <- read_pkgdownignore(pkg$src_path)
  expect_equal(result, "INTERNAL.md")
})

test_that("read_pkgdownignore reads from _pkgdown/ directory", {
  pkg <- local_pkgdown_site()
  dir_create(path(pkg$src_path, "_pkgdown"))
  writeLines("NOTES.md", path(pkg$src_path, "_pkgdown", ".pkgdownignore"))

  result <- read_pkgdownignore(pkg$src_path)
  expect_equal(result, "NOTES.md")
})

test_that("read_pkgdownignore combines files from multiple locations", {
  pkg <- local_pkgdown_site()

  # Root

  writeLines("CLAUDE.md", path(pkg$src_path, ".pkgdownignore"))

  # pkgdown/
  dir_create(path(pkg$src_path, "pkgdown"))
  writeLines("AGENTS.md", path(pkg$src_path, "pkgdown", ".pkgdownignore"))

  result <- read_pkgdownignore(pkg$src_path)
  expect_setequal(result, c("CLAUDE.md", "AGENTS.md"))
})

test_that("read_pkgdownignore ignores comments and empty lines", {
  pkg <- local_pkgdown_site()
  writeLines(
    c(
      "# This is a comment",
      "CLAUDE.md",
      "",
      "  # Indented comment",
      "AGENTS.md",
      "   ",
      "INTERNAL.md"
    ),
    path(pkg$src_path, ".pkgdownignore")
  )

  result <- read_pkgdownignore(pkg$src_path)
  expect_equal(result, c("CLAUDE.md", "AGENTS.md", "INTERNAL.md"))
})

test_that("read_pkgdownignore trims whitespace", {
  pkg <- local_pkgdown_site()
  writeLines(
    c("  CLAUDE.md  ", "\tAGENTS.md\t"),
    path(pkg$src_path, ".pkgdownignore")
  )

  result <- read_pkgdownignore(pkg$src_path)
  expect_equal(result, c("CLAUDE.md", "AGENTS.md"))
})

test_that("read_pkgdownignore deduplicates entries", {
  pkg <- local_pkgdown_site()

  # Same file in root and pkgdown/

  writeLines("CLAUDE.md", path(pkg$src_path, ".pkgdownignore"))
  dir_create(path(pkg$src_path, "pkgdown"))
  writeLines("CLAUDE.md", path(pkg$src_path, "pkgdown", ".pkgdownignore"))

  result <- read_pkgdownignore(pkg$src_path)
  expect_equal(result, "CLAUDE.md")
})

test_that("package_mds excludes files listed in .pkgdownignore", {
  pkg <- local_pkgdown_site()

  # Create test markdown files
  writeLines("# CLAUDE", path(pkg$src_path, "CLAUDE.md"))
  writeLines("# AGENTS", path(pkg$src_path, "AGENTS.md"))
  writeLines("# ROADMAP", path(pkg$src_path, "ROADMAP.md"))

  # Create .pkgdownignore

  writeLines(c("CLAUDE.md", "AGENTS.md"), path(pkg$src_path, ".pkgdownignore"))

  result <- package_mds(pkg$src_path)
  result_files <- path_file(result)

  expect_false("CLAUDE.md" %in% result_files)
  expect_false("AGENTS.md" %in% result_files)
  expect_true("ROADMAP.md" %in% result_files)
})

test_that("package_mds excludes .github files listed in .pkgdownignore", {
  pkg <- local_pkgdown_site()

  # Create .github directory with markdown files
  dir_create(path(pkg$src_path, ".github"))
  writeLines("# Internal", path(pkg$src_path, ".github", "INTERNAL.md"))
  writeLines("# Contributing", path(pkg$src_path, ".github", "CONTRIBUTING.md"))

  # Ignore the internal one
  writeLines("INTERNAL.md", path(pkg$src_path, ".pkgdownignore"))

  result <- package_mds(pkg$src_path)
  result_files <- path_file(result)

  expect_false("INTERNAL.md" %in% result_files)
  expect_true("CONTRIBUTING.md" %in% result_files)
})

test_that("package_mds works when .pkgdownignore is empty", {
  pkg <- local_pkgdown_site()

  # Create test file
  writeLines("# ROADMAP", path(pkg$src_path, "ROADMAP.md"))

  # Empty ignore file
  file_create(path(pkg$src_path, ".pkgdownignore"))

  result <- package_mds(pkg$src_path)
  result_files <- path_file(result)

  expect_true("ROADMAP.md" %in% result_files)
})

test_that("package_mds works when .pkgdownignore has only comments", {
  pkg <- local_pkgdown_site()

  # Create test file
  writeLines("# ROADMAP", path(pkg$src_path, "ROADMAP.md"))

  # Ignore file with only comments
  writeLines(
    c("# comment 1", "# comment 2"),
    path(pkg$src_path, ".pkgdownignore")
  )

  result <- package_mds(pkg$src_path)
  result_files <- path_file(result)

  expect_true("ROADMAP.md" %in% result_files)
})
