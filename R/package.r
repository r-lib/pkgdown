build_package <- function(package, base_path) {
  if (!file.exists(base_path)) dir.create(base_path)
  copy_bootstrap(base_path)
  
  info <- package_info(package)
  info$vignettes <- build_vignettes(package, base_path)
  render_template("index", info, file.path(base_path, "index.html"))
  
  build_topics(package, base_path)
  
  invisible(TRUE)
}

#' Generate all topic pages for a package.
#'
build_topics <- function(package, base_path) {
  index <- topic_index(package)

  # for each file, find name of one topic
  topics <- index$alias[!duplicated(index$file)]
  paths <- file.path(base_path, index$file[!duplicated(index$file)])
  
  for (i in seq_along(topics)) {
    rd <- parse_rd(topics[[i]], package)
    html <- to_html(rd, 
      env = new.env(parent = globalenv()), 
      base_path = base_path, 
      topic = topics[[i]])
    render_template("topic", html, paths[[i]])
  }
  
  invisible(TRUE)
}

copy_bootstrap <- function(base_path) {
  bootstrap <- file.path(inst_path(), "bootstrap")
  file.copy(dir(bootstrap, full.names = TRUE), base_path, recursive = TRUE)
}


topic_index <- function(package) {
  index_path <- system.file("help", "AnIndex", package = package)

  topics <- read.table(index_path, sep = "\t", 
    stringsAsFactors = FALSE, comment.char = "", quote = "", header = FALSE)
    
  names(topics) <- c("alias", "file") 
  topics$file <- str_c(topics$file, ".html")
  topics[complete.cases(topics), ]
}


package_info <- function(package) {
  
  info <- readRDS(system.file("Meta", "package.rds", package = package))
  desc <- as.list(info$DESCRIPTION)
  
  out <- list()
  
  out$package <- desc$Package
  out$version <- desc$Version
  out$description <- desc$Description
  
  out$authors <- desc$Author
  out$maintainer <- desc$Maintainer
  if (!is.null(desc$url)) {
    out$urls <- str_trim(str_split(desc$url, ",")[[1]])    
  }

  # Dependencies 
  pkg_names <- function(x) vapply(x, "[[", "name", FUN.VALUE = character(1))
  out$dependencies <- list(
    depends = pkg_names(info$depends),
    imports = pkg_names(info$imports),
    suggests = pkg_names(info$suggests),
    extends = pkg_names(info$extends)
  )

  # Topics
  index <- topic_index(package)
  out$topics <- unname(apply(index, 1, as.list))

  out
}


#' List all package vignettes.
#'
#' Copies all vignettes and returns data structure suitable for use with
#' whisker templates.
#'
#' @param package package to explore
#' @return a list, with one element for each vignette containing the vignette
#'   title and file name.
build_vignettes <- function(package, base_path) {
  vignettes <- as.data.frame(vignette(package = package)$results)
  
  title <- str_replace_all(vignettes$Title, " \\(source, pdf\\)", "")
  filename <- str_c(vignettes$Item, ".pdf")
  src <- file.path(vignettes$LibPath, vignettes$Package, "doc", filename)
    
  dest <- file.path(base_path, "vignettes")
  if (!file.exists(dest)) dir.create(dest)
  
  file.copy(src, file.path(dest, filename))
  
  apply(cbind(src, filename), 1, as.list)
}

