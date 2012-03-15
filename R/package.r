#' Package information.
#'
#' @aliases helpr_package helpr_package_mem
#' @return all the information necessary to produce a package site ("/package/:package/")
helpr_package <- function(package) {
  helpr_package_mem(package, pkg_version(package))
}



helpr_package_mem <- function(package, version) {
  
  info <- readRDS(system.file("Meta", "package.rds", package = package))
  description <- as.list(info$DESCRIPTION)
  info$DESCRIPTION <- NULL
  description <- modifyList(info, description)
  names(description) <- tolower(names(description))
  
  author_str <- pluralize("Author", description$author)
  
  items <- pkg_topics_alias(package)
  
  demos <- pkg_demos(package)
  vigs <- pkg_vigs(package)

  description$depends <- parse_pkg_desc_item(description$depends)
  description$imports <- parse_pkg_desc_item(description$imports)
  description$suggests <- parse_pkg_desc_item(description$suggests)
  description$extends <- parse_pkg_desc_item(description$extends)
  description$reverse <- dependsOnPkgs(package)
  description$author <- pkg_author_and_maintainers(description$author, description$maintainer)
  description$maintainer <- NULL

  if (has_text(description$url)) {
    description$url <- str_trim(str_split(description$url, ",")[[1]])
  }

  list(
    package = package, 
    items = items,
    description = description, 
    author_str = author_str, 
    demos_str = pluralize("Demo", demos),
    demos = demos,
    vigs_str = pluralize("Vignette", vigs),
    vigs = vigs,
    change_log = pkg_news(package)
  )
}

#' Package version from the rd file
#'
#' @keywords internal
#' @author Hadley Wickham
pkg_version <- function(pkg) {
  rds <- read_rds(system.file("Meta", "package.rds", package = pkg))
  rds$DESCRIPTION[["Version"]]
}


#' Add package link to a string.
#' 
#' @param string string to be evaluated
#' @keywords internal
#' @author Barret Schloerke \email{schloerke@@gmail.com}
#' @examples #add_package_link_to_string("quantreg, Hmisc, mapproj, maps, hexbin, gpclib, maptools")
add_package_link_to_string <- function(string) {
  packs <- str_trim(str_split(usage_functions(string), "[, ]")[[1]])
  packs <- packs[packs != ""]
  pack_link <- str_c("<a href='", router_url(), "/package/", packs, "/' >", packs, "</a>")

  for(i in seq_along(packs)){
    string <- str_replace(string, packs[i], pack_link[i])[[1]]
  }
  string
}

#' Ensure package version is properly displayed (if not already in a nice
#' format).
#'
parse_pkg_desc_item <- function(obj) {
  if (NROW(obj) < 1) {
    return(NULL)
  }
  
  if (is.character(obj)) {
    return(obj)
  }
  
  if (!is.list(obj)) {
    obj <- list(obj = (list(name = obj, version = NULL)))
  }

  as.data.frame(
    sapply(obj, function(x) {
      vers <- NULL
      
      # if the version is found, it will create one in the form of '(1.2.3)'
      if (!is.null(x$version)) {
        vers <- str_c("(", x$op, " ", str_c(unclass(x$version)[[1]], collapse = "."), ")", collapse = "")
      }
      list(name = as.character(x$name), version = as.character(vers))
    })
    , stringsAsFactors = FALSE
  )
}


#' List all package vignettes.
#'
#' @param package package to explore
#' @return \code{subset} of the \code{vignette()$results} \code{data.frame} ("Package", "LibPath", "Item" and "Title")
pkg_vigs <- function(package) {
  vignettes <- vignette(package = package)$results
  
  if (!NROW(vignettes)) {
    return(NULL)
  }

  titles <- str_replace_all(vignettes[,4], "source, pdf", "")
  titles <- str_trim(str_replace_all(titles, "[()]", ""))
  
  data.frame(item = vignettes[,"Item"], title = titles, stringsAsFactors = FALSE)
}

#' Package topics alias to file index.
#'
#' @param package package to explore
#' @return \code{\link{data.frame}} containing \code{alias} (function name) and \code{file} that it is associated with
#' @keywords internal
#' @author Hadley Wickham
pkg_topics_index <- function(package) {
  help_path <- pkg_help_path(package)
  
  file_path <- file.path(help_path, "AnIndex")
  ### check to see if there is anything that exists, aka sinartra
  if (length(readLines(file_path, n = 1)) < 1) {
    return(NULL)
  }

  topics <- read.table(file_path, sep = "\t", 
    stringsAsFactors = FALSE, comment.char = "", quote = "", header = FALSE)
    
  names(topics) <- c("alias", "file") 
  topics[complete.cases(topics), ]
}


#' Topic title and aliases by package.
#' return information on the package, datasets, internal, and datasets
#'
#' @param pkg package in question
pkg_topics_alias <- function(pkg) {
    
  rd1 <- pkg_topics_rd(pkg)
  rd <- lapply(rd1, function(x) {
    desc <- to_html(untag(x$description), pkg)
    desc_naked <- strip_html(desc)
    if (str_length(desc_naked) > 150) {
      desc <- str_c(str_sub(desc_naked, end = 150), " ...")
    }

    list(
      topic = unlist(x$name),
      alias = unname(sapply(x[names(x) == "alias"], "[[", 1)),
      keywords = str_trim(to_html(untag(x$keyword), pkg)),
      desc = desc,
      title = to_html(untag(x$title), pkg)
    )
  })

  keywords <- sapply(rd, function(x){ x$keywords })
          
  package_info <- rd[keywords == "package"]
  internal <- rd[keywords == "internal"]
  dataset <- rd[keywords == "datasets"]  
  
  rows <- keywords %in% c("package", "internal", "datasets")

  if (sum(rows) > 0) rd[rows] <- NULL 
  
  list(func = rd, dataset = dataset, internal = internal, info = package_info)
}

#' Package description
#'
#' @param pkg package in question
#' @param topic topic in question
package_description <- function(pkg, topic) {
  gsub("$\n+|\n+^", "", to_html(pkg_topic(pkg, topic)$description, package))
}

