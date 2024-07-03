activate_navbar <- function(html, path, pkg = list(bs_version = 5)) {
  if (pkg$bs_version <= 3) {
    return()
  }

  path <- remove_useless_parts(path, pkg = pkg)

  # Get nav items, their links, their similarity to the current path
  navbar_haystack <- navbar_links_haystack(html, pkg, path)
  if (nrow(navbar_haystack) == 0) {
    return()
  }

  # Pick the most similar link, activate the corresponding nav item
  best_match <- navbar_haystack[which.max(navbar_haystack$similar), ]
  tweak_class_prepend(best_match$nav_item[[1]], "active")

  invisible()
}

navbar_links_haystack <- function(html, pkg, path) {
  # Extract links from the menu items
  html_navbar <- xml2::xml_find_first(html, ".//div[contains(@class, 'navbar')]")
  nav_items <- xml2::xml_find_all(html_navbar,".//li[contains(@class, 'nav-item')]")

  get_hrefs <- function(nav_item, pkg = pkg) {
    href <- xml2::xml_attr(xml2::xml_child(nav_item), "href")

    if (!is.na(href) && href != "#") {
      links <- href
    } else {
      # links in a drop-down
      hrefs <- xml2::xml_attr(xml2::xml_find_all(nav_item, ".//a"), "href")
      links <- hrefs[hrefs != "#"]
    }

    tibble::tibble(
      nav_item = list(nav_item),
      links = remove_useless_parts(links[is_internal_link(links, pkg = pkg)], pkg = pkg)
    )
  }

  haystack <- do.call(rbind, lapply(nav_items, get_hrefs, pkg = pkg))

  # For each link, calculate similarity to the current path
  separate_path <- function(link) {
    strsplit(link, "/")[[1]]
  }
  get_similarity <- function(stalk, needle) {
    needle <- separate_path(needle)
    stalk <- separate_path(stalk)

    # Active item can't be more precise than current path/needle
    if (length(stalk) > length(needle)) {
      return(0)
    }

    # Active item can however be less precise than current path/needle
    length(stalk) <- length(needle)
    similar <- (needle == stalk)

    # Any difference indicates it's not the active item
    if (any(!similar, na.rm = TRUE)) {
      0
    } else {
      sum(similar, na.rm = TRUE)
    }
  }
  haystack$similar <- purrr::map_dbl(haystack$links, get_similarity, needle = path)

  # Only return rows of links with some similarity to the current path
  haystack[haystack$similar > 0, ]
}

remove_useless_parts <- function(links, pkg) {
  # remove website URL
  if (!is.null(pkg$meta$url)) {
    links <- sub(pkg$meta$url, "", links)
  }
  # remove first slash from path
  links <- sub("^/", "", links)
  # remove /index.html from the end
  links <- sub("/index.html/?", "", links)
  # remove ../ from the beginning
  links <- gsub("\\.\\./", "", links)

  links
}
