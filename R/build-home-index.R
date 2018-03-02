build_home_index <- function(pkg) {
  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)
  scoped_file_context(depth = 0)

  data <- data_home(pkg)
  data$opengraph <- list(description = pkg$desc$get("Description")[[1]])

  if (is.null(data$path)) {
    data$index <- linkify(pkg$desc$get("Description")[[1]])
    render_page(pkg, "home", data, "index.html")
  } else {
    file_name <- tools::file_path_sans_ext(basename(data$path))
    file_ext <- tools::file_ext(data$path)

    if (file_ext == "md") {
      data$index <- markdown(path = data$path)
      render_page(pkg, "home", data, "index.html")
    } else if (file_ext == "Rmd") {
      if (identical(file_name, "README")) {
        # Render once so that .md is up to date
        cat_line("Updating ", file_name, ".md")
        callr::r_safe(
          function(input, encoding) {
            rmarkdown::render(
              input,
              output_format = "github_document",
              output_options = list(html_preview = FALSE),
              quiet = TRUE,
              encoding = "UTF-8",
              envir = globalenv()
            )
          },
          args = list(
            input = data$path
          )
        )
      }

      input <- path(pkg$dst_path, path_file(data$path))
      file_copy(data$path, input, overwrite = TRUE)
      on.exit(file_delete(input))

      render_rmd(pkg, input, "index.html",
        depth = 0L,
        data = data,
        toc = FALSE,
        strip_header = TRUE
      )
    }
  }

  update_homepage_html(
    path(pkg$dst_path, "index.html"),
    isTRUE(pkg$meta$home$strip_header)
  )
}


update_homepage_html <- function(path, strip_header = FALSE) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  tweak_homepage_html(html, strip_header = strip_header)

  xml2::write_html(html, path, format = FALSE)
  path
}

data_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  path <- find_first_existing(pkg$src_path,
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
  if (!is.null(pkg$meta$home$sidebar))
    return(pkg$meta$home$sidebar)

  paste0(
    data_home_sidebar_links(pkg),
    data_home_sidebar_license(pkg),
    data_home_sidebar_citation(pkg),
    data_home_sidebar_authors(pkg),
    collapse = "\n"
  )
}

data_home_sidebar_links <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  links <- c(
    data_link_repo(pkg),
    data_link_github(pkg),
    data_link_bug_report(pkg),
    data_link_meta(pkg)
  )

  list_with_heading(links, "Links")
}

data_link_meta <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  links <- pkg$meta$home$links

  if (length(links) == 0)
    return(character())

  links %>%
    purrr::transpose() %>%
    purrr::pmap_chr(link_url)
}

data_link_github <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  urls <- pkg$desc$get("URL") %>%
    strsplit(",\\s+") %>%
    `[[`(1)

  github <- grepl("github\\.com", urls)

  if (!any(github))
    return(character())

  link_url("Browse source code", urls[which(github)[[1]]])
}

data_link_bug_report <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  bug_reports <- pkg$desc$get("BugReports")[[1]]

  if (is.na(bug_reports))
    return(character())

  link_url("Report a bug", bug_reports)
}

data_link_repo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  name <- pkg$desc$get("Package")[[1]]
  repo_result <- repo_url(name)

  if (is.null(repo_result))
    return(list())

  if (names(repo_result) == "CRAN")
    repo_link <- paste0("https://cran.r-project.org/package=", name)
  else if (names(repo_result) == "BIOC")
    repo_link <- paste0("https://www.bioconductor.org/packages/", name)
  else
    stop("Package link not supported")

  link_url(
    paste0("Download from ", names(repo_result)),
    repo_link
  )
}

cran_mirror <- function() {
  cran <- as.list(getOption("repos"))[["CRAN"]]
  if (is.null(cran) || identical(cran, "@CRAN@")) {
    "https://cran.rstudio.com"
  } else {
    cran
  }
}

bioc_mirror <- function() {
  if (requireNamespace("BiocInstaller", quietly = TRUE)) {
    bioc <- BiocInstaller::biocinstallRepos()[["BioCsoft"]]
  } else {
    bioc <- "https://bioconductor.org/packages/release/bioc"
  }
  bioc
}

repo_url <- function(pkg, cran = cran_mirror(), bioc = bioc_mirror()) {
  bioc_pkgs <- utils::available.packages(contriburl = paste0(bioc, "/src/contrib"))
  cran_pkgs <- utils::available.packages(contriburl = paste0(cran, "/src/contrib"))
  avail <- if (pkg %in% rownames(cran_pkgs)) {
    c(CRAN = paste0(cran, "/web/packages/", pkg, "/index.html"))
  } else if (pkg %in% rownames(bioc_pkgs)) {
    c(BIOC = paste0(bioc, "/html/", pkg, ".html"))
  } else { NULL }
  return(avail)
}

link_url <- function(text, href) {
  label <- gsub("(/+)", "\\1&#8203;", href)
  paste0(text, " at <br /><a href='", href, "'>", label, "</a>")
}

linkify <- function(text) {
  text <- escape_html(text)
  text <- gsub("&lt;doi:([^&]+)&gt;",  # DOIs with < > & are not supported
               "&lt;<a href='https://doi.org/\\1'>doi:\\1</a>&gt;",
               text, ignore.case = TRUE)
  text <- gsub("&lt;arXiv:([^&]+)&gt;",
               "&lt;<a href='https://arxiv.org/abs/\\1'>arXiv:\\1</a>&gt;",
               text, ignore.case = TRUE)
  text <- gsub("&lt;((http|ftp)[^&]+)&gt;",  # URIs with & are not supported
               "&lt;<a href='\\1'>\\1</a>&gt;",
               text)
  text
}
