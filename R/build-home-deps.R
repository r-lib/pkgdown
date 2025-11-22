build_home_depencies <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  deps <- dependencies_table(pkg)
  cats <- split(deps$package, deps$type)
  cats <- purrr::map_chr(cats, paste0, collapse = ", ")

  # Need to translate category titles
  paste0("<p>", names(cats), ": ", cats, "</p>")
}

dependencies_table <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  deps <- pkg$desc$get_deps()
  deps <- deps[order(deps$type, deps$package), c("package", "type")]
  deps <- deps[deps$package != "R", ]

  recursive <- sort(unique(unlist(tools::package_dependencies(deps$package[deps$type %in% c("Depends", "Imports")]))))
  recursive <- setdiff(recursive, deps$package)
  deps <- rbind(deps, data.frame(package = recursive, type = "Recursive"))

  deps$package <- purrr::map_chr(deps$package, package_link)
  rownames(deps) <- NULL

  deps
}

package_link <- function(package) {
  href <- downlit::href_package(package)

  if (is.na(href)) {
    if (is_base_package(package)) {
      href <- NA
    } else {
      href <- paste0("https://cran.r-project.org/web/packages/", package)
    }
  }
  
  a(package, href)
}

is_base_package <- function(x) {
  x %in% c(
    "base", "compiler", "datasets", "graphics", "grDevices", "grid",
    "methods", "parallel", "splines", "stats", "stats4", "tcltk",
    "tools", "utils"
  )
}
