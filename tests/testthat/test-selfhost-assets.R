test_that("CSS files for all bootswatch themes are available", {
  local <-
    fs::path_package(package = "pkgdown", "assets/external/bootswatch") %>%
    fs::dir_ls(type = "file", glob = "*.min.css") %>%
    utils::strcapture(
      pattern = "(\\w+?)(?:\\.min\\.css$)",
      proto = data.frame(present = character())
    )

  expect_length(shinythemes:::allThemes()[!(shinythemes:::allThemes() %in% local$present)],
                0L)
})
