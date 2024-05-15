# Menu constructors -----------------------------------------------------------

# Helpers for use within pkgdown itself
menu_submenu <- function(text, children) {
  if (length(children) == 0) {
    return()
  } else {
    list(text = text, children = children)
  }
}
menu_link <- function(text, href, target = NULL) {
  purrr::compact(list(text = text, href = href, target = target))
}
menu_links <- function(text, href) {
  purrr::map2(text, href, menu_link)
}
menu_heading <- function(text, ...) list(text = text, ...)
menu_separator <- function() list(text = "---------")
menu_search <- function() list(search = list())
menu_icon <- function(icon, href, label) {
  list(icon = icon, href = href, "aria-label" = label)
}

menu_type <- function(x) {
  if (!is.list(x) || !is_named(x)) {
    not <- obj_type_friendly(x)
    cli::cli_abort("Navbar components must be named lists, not {not}.")
  } else if (!is.null(x$menu)) {
    # https://github.com/twbs/bootstrap/pull/6342
    cli::cli_abort("Nested menus are not supported.")
  } else if (!is.null(x$children)) {
    "menu"
  } else if (!is.null(x$text) && grepl("^\\s*-{3,}\\s*$", x$text)) {
    "separator"
  } else if (!is.null(x$text) && is.null(x$href)) {
    "heading"
  } else if ((!is.null(x$text) || !is.null(x$icon)) && !is.null(x$href)) {
    "link"
  } else if (!is.null(x$search)) {
    "search"
  } else if (!is_named(x)) {
    "list"
  } else {
    cli::cli_abort("Unknown navbar component with names {names(x)}.")
  }
}

# Menu renderers --------------------------------------------------------------

navbar_html <- function(x, path_depth = 0L, menu_depth = 0L, side = c("left", "right")) {
  if (is.null(x)) {
    return("")
  }

  side <- arg_match(side)
  type <- menu_type(x)

  text <- switch(type, 
    menu = navbar_html_menu(x, menu_depth = menu_depth, path_depth = path_depth, side = side),
    heading = navbar_html_heading(x),
    link = navbar_html_link(x, menu_depth = menu_depth),
    separator = navbar_html_separator(),
    search = navbar_html_search(x, path_depth = path_depth)
  )

  class <- c(
    if (menu_depth == 0L) "nav-item",
    if (type == "menu") "dropdown"
  )
  html_tag("li", class = class, text)
}

navbar_html_list <- function(x, path_depth = 0L, menu_depth = 0L, side = "left") {
  tags <- purrr::map_chr(
    x,
    navbar_html,
    path_depth = path_depth,
    menu_depth = menu_depth,
    side = side
  )
  paste0(tags, collapse = "\n")
}

navbar_html_menu <- function(x, path_depth = 0L, menu_depth = 0L, side = "left") {
  id <- paste0("dropdown-", make_slug(x$text))

  button <- html_tag("button",
    type = "button",
    class = c(if (menu_depth == 0L) "nav-link", "dropdown-toggle"),
    id = id,
    `data-bs-toggle` = "dropdown",
    "aria-expanded" = "false",
    "aria-haspopup" = "true",
    "aria-label" = x$`aria-label`,
    navbar_html_text(x),
  )

  li <- navbar_html_list(
    x$children,
    path_depth = path_depth,
    menu_depth = menu_depth + 1,
    side = side
  )
  ul <- html_tag(
    "ul",
    class = c("dropdown-menu", if (side == "right") "dropdown-menu-end"),
    "aria-labelledby" = id,
    paste0("\n", indent(li, "  "), "\n")
  )

  paste0("\n", indent(paste0(button, "\n", ul), "  "), "\n")
}

navbar_html_link <- function(x, menu_depth = 0) {
  html_tag(
    "a",
    class = if (menu_depth == 0) "nav-link" else "dropdown-item",
    href = x$href,
    target = x$target,
    "aria-label" = x$`aria-label`,
    navbar_html_text(x)
  )
}

navbar_html_heading <- function(x) {
  html_tag(
    "h6",
    class = "dropdown-header",
    "data-toc-skip" = NA,
    navbar_html_text(x)
  )
}

navbar_html_separator <- function() {
  '<hr class="dropdown-divider">'
}

navbar_html_search <- function(x, path_depth = 0) {
  input <- html_tag(
    "input",
    type = "search",
    class = "form-control",
    name = "search-input",
    id = "search-input",
    autocomplete = "off",
    "aria-label" = tr_("Search site"),
    placeholder = tr_("Search for"),
    "data-search-index" = paste0(up_path(path_depth), "search.json")
  )

  html_tag("form", class = "form-inline", role = "search", "\n", input, "\n")
}

# Reused HTML components -----------------------------------------------------

html_tag <- function(tag, ..., class = NULL) {
  dots <- list2(...)
  dots_attr <- dots[names2(dots) != ""]
  dots_child <- dots[names2(dots) == ""]

  if (!is.null(class)) {
    class <- paste0(class, collapse = " ")
  }
  attr <- purrr::compact(c(list(class = class), dots_attr))
  if (length(attr) > 0) {
    html_attr <- ifelse(
      is.na(attr), 
      names(attr),
      paste0(names(attr), '="', attr, '"')
    )
    html_attr <- paste0(" ", paste0(html_attr, collapse = " "))
  } else {
    html_attr <- ""
  }
 
  html_child <- paste0(purrr::compact(dots_child), collapse = " ")
  needs_close <- !tag %in% "input"

  paste0(
    "<", tag, html_attr, ">",
    html_child,
    if (needs_close) paste0("</", tag, ">")
  )
}

navbar_html_text <- function(x) {
  if (is.null(x$icon)) {
    icon <- ""
  } else {
    # Extract icon set from class name
    classes <- strsplit(x$icon, " ")[[1]]
    icon_classes <- classes[grepl("-", classes)]
    iconset <- purrr::map_chr(strsplit(icon_classes, "-"), 1)
    
    icon <- html_tag("span", class = unique(c(iconset, classes)))
  }

  paste0(
    icon,
    if (!is.null(x$icon) && !is.null(x$text)) " ",
    escape_html(x$text)
  )
}

indent <- function(x, indent) {
  paste0(indent, gsub("\n", paste0("\n", indent), x))
}