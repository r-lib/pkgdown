test_that("build_llm_docs() works", {
  skip_if_no_pandoc()
  pkg <- local_pkgdown_site(
    desc = list(
      Package = "pkgdown",
      Description = "My package does great things!"
    )
  )

  build_site(pkg, install = FALSE, new_process = FALSE)

  llms_txt <- path(pkg$dst_path, "llms.txt")
  expect_snapshot_file(llms_txt)

  index_md <- path(pkg$dst_path, "index.md")
  expect_snapshot_file(index_md)
})
