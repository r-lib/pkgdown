data_navbar <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  # Take structure as is from meta
  navbar <- purrr::pluck(pkg, "meta", "navbar")
  structure <- navbar$structure %||% navbar_structure()

  # Merge components from meta
  components <- navbar_components(pkg)
  components_meta <- navbar$components %||% list()
  components[names(components_meta)] <- components_meta
  components <- purrr::compact(components)

  # Any unplaced components go to the right of the left navbar
  right_comp <- intersect(structure$right, names(components))
  left_comp <- intersect(structure$left, names(components))
  extra_comp <- setdiff(names(components), c(left_comp, right_comp))

  # Backward compatiblity
  left <- navbar$left %||% components[c(left_comp, extra_comp)]
  right <- navbar$right %||% components[right_comp]

  list(
    type = navbar$type %||% "light",
    bg = navbar$bg %||% "light",
    left = render_navbar_links(left, depth = depth),
    right = render_navbar_links(right, depth = depth)
  )
}

render_navbar_links <- function(x, depth = 0L) {
  stopifnot(is.integer(depth), depth >= 0L)

  tweak <- function(x) {
    if (!is.null(x$menu)) {
      x$menu <- lapply(x$menu, tweak)
      x
    } else if (!is.null(x$href) && !grepl("://", x$href, fixed = TRUE)) {
      x$href <- paste0(up_path(depth), x$href)
      x
    } else {
      x
    }
  }

  if (depth != 0L) {
    x <- lapply(x, tweak)
  }

  bs4_navbar_links_html(x)
}

# Default navbar ----------------------------------------------------------

navbar_structure <- function() {
  print_yaml(list(
    left = c("home", "intro", "reference", "articles", "tutorials", "news"),
    right = "github"
  ))
}

navbar_components <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  menu <- list()
  menu$home <- menu_icon("home", "index.html")
  menu$reference <- menu_link("Reference", "reference/index.html")
  menu$tutorials <- menu("Tutorials",
    menu_links(pkg$tutorials$title, pkg$tutorials$file_out)
  )

  vignettes <- pkg$vignettes
  pkg_intro <- vignettes$name == pkg$package
  if (any(pkg_intro)) {
    intro <- vignettes[pkg_intro, , drop = FALSE]
    vignettes <- vignettes[!pkg_intro, , drop = FALSE]

    menu$intro <- menu_link("Get started", intro$file_out)
  }
  menu$articles <-  menu("Articles", menu_links(vignettes$title, vignettes$file_out))
  menu$news <- navbar_news(pkg)

  if (!is.null(pkg$github_url)) {
    menu$github <- menu_icon("github", pkg$github_url, style = "fab")
  }

  print_yaml(menu)
}

# Menu helpers -------------------------------------------------------------

menu <- function(text, children) {
  if (length(children) == 0)
    return()
  list(text = text, menu = children)
}
menu_link <- function(text, href) {
  list(text = text, href = href)
}
menu_links <- function(text, href) {
  purrr::map2(text, href, ~ list(text = .x, href = .y))
}
menu_icon <- function(icon, href, style = "fas") {
  list(icon = paste0(style, " fa-", icon, " fa-lg"), href = href)
}
menu_text <- function(text) {
  list(text = text)
}
menu_spacer <- function() {
   menu_text("---------")
}

# navbar_links ------------------------------------------------------------

bs4_navbar_links_html <- function(links) {
  as.character(bs4_navbar_links_tags(links))
}

#' @importFrom htmltools tags tagList
bs4_navbar_links_tags <- function(links, depth = 0L) {

  # sub-menu
  is_submenu <- depth > 0L

  if (!is.null(links)) {

    tags <- lapply(links, function(x) {

      if (!is.null(x$menu)) {


        if (is_submenu) {
          menu_class <- "dropdown-item"
          link_text <- bs4_navbar_link_text(x)
        } else {
          menu_class <- "nav-item dropdown"
          link_text <- bs4_navbar_link_text(x)
        }

        submenuLinks <- bs4_navbar_links_tags(x$menu, depth = depth + 1L)

        tags$li(
          class = menu_class,
          tags$a(
            href = "#", class = "nav-link dropdown-toggle",
            `data-toggle` = "dropdown", role = "button",
            `aria-expanded` = "false", `aria-haspopup` = "true",
            link_text
          ),
          tags$div(
            class = "dropdown-menu",
            `aria-labelledby` ="navbarDropdown",
            submenuLinks
          )
        )

      } else if (!is.null(x$text) && grepl("^\\s*-{3,}\\s*$", x$text)) {

        # divider
        tags$div(class = "dropdown-divider")

      } else if (!is.null(x$text) && is.null(x$href)) {
        # header
        tags$h6(class = "dropdown-header", `data-toc-skip` = NA, x$text)

      } else {
        # standard menu item
        textTags <- bs4_navbar_link_text(x)

        if (is_submenu) {
          tags$a(
            class = "dropdown-item",
            href = x$href,
            textTags
          )
        } else {
          tags$li(
            class = "nav-item",
            tags$a(
              class = "nav-link",
              href = x$href,
              textTags
            )
          )
        }
      }
    })
    tagList(tags)
  } else {
    tagList()
  }
}

bs4_navbar_link_text <- function(x, ...) {

  if (!is.null(x$icon)) {
    # find the iconset
    split <- strsplit(x$icon, "-")
    if (length(split[[1]]) > 1)
      iconset <- split[[1]][[1]]
    else
      iconset <- ""
    tagList(tags$span(class = paste(iconset, x$icon)), " ", x$text, ...)
  }
  else
    tagList(x$text, ...)
}

