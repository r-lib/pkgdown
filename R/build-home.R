#' Build home page
#'
#' First looks for \code{index.Rmd} or \code{README.Rmd}, then
#' \code{index.md} or \code{README.md}. If none are found, falls back to the
#' description field in \code{DESCRIPTION}.
#'
#' @section YAML config:
#' To tweak the home page, you need a section called \code{home}.
#'
#' You can add additional links to the sidebar with a subsection called
#' \code{links}, which should contain a list of \code{text} + \code{href}
#' elements:
#'
#' \preformatted{
#' home:
#'   links:
#'   - text: Link text
#'     href: http://website.com
#' }
#'
#' @inheritParams build_articles
#' @export
build_home <- function(pkg = ".", path = "docs", depth = 0L) {
  rule("Building home")

  pkg <- as_pkgdown(pkg)
  data <- data_home(pkg)

  if (identical(tools::file_ext(data$path), "Rmd")) {
    input <- file.path(path, basename(data$path))
    file.copy(data$path, input)
    on.exit(unlink(input))

    render_rmd(pkg, input, "index.html",
      depth = depth,
      data = data,
      toc = FALSE,
      strip_header = TRUE
    )
  } else {
    if (is.null(path)) {
      data$index <- pkg$description
    } else {
      data$index <- markdown(path = data$path, depth = 0L, index = pkg$topics)
    }
    render_page(pkg, "home", data, out_path(path, "index.html"), depth = depth)
  }

  invisible()
}


data_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  path <- find_first_existing(pkg$path,
    c("index.Rmd", "README.Rmd", "index.md", "README.md")
  )

  print_yaml(list(
    pagetitle = pkg$desc$get("Title")[[1]],
    sidebar = data_home_sidebar(pkg),
    path = path
  ))
}

data_home_sidebar <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  links <- c(
    data_link_cran(pkg),
    data_link_github(pkg),
    data_link_bug_report(pkg),
    data_link_meta(pkg)
  )

  if (length(links) == 0)
    return(NULL)

  bullets <- links %>%
    purrr::map_chr(~ paste0("<li><a href='", . $href, "'>", .$text, "</a></li>"))

  paste0(
    "<h2>Links</h2>",
    "<ul>\n",
    paste0(bullets, collapse = "\n"), "\n",
    "</ul>\n"
  )

}

data_link_meta <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  pkg$meta$home$links
}

data_link_github <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  urls <- pkg$desc$get("URL") %>%
    strsplit(",\\s+") %>%
    `[[`(1)

  github <- grepl("github", urls)

  if (!any(github))
    return(list())

  list(
    list(
      href = urls[which(github)[[1]]],
      text = "Browse source code"
    )
  )
}

data_link_bug_report <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  bug_reports <- pkg$desc$get("BugReports")[[1]]

  if (is.na(bug_reports))
    return(list())

  list(
    list(
      href = bug_reports,
      text = "Report a bug"
    )
  )
}

data_link_cran <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  name <- pkg$desc$get("Package")[[1]]
  if (!on_cran(name))
    return(list())

  list(
    list(
      href = paste0("https://cran.r-project.org/package=", name),
      text = "CRAN home"
    )
  )
}

on_cran <- function(pkg) {
  pkgs <- utils::available.packages(type = "source")
  pkg %in% rownames(pkgs)
}
