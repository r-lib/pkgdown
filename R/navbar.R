data_navbar <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  # Take structure as is from meta
  navbar <- purrr::pluck(pkg, "meta", "navbar")
  structure <- modify_list(navbar_structure_defaults(), navbar$structure)

  # Merge components from meta
  components <- navbar_components(pkg)
  components_meta <- navbar$components %||% list()
  components[names(components_meta)] <- components_meta
  components <- purrr::compact(components)

  right_comp <- intersect(structure$right, names(components))
  left_comp <- intersect(structure$left, names(components))

  # Backward compatiblity
  left <- navbar$left %||% components[left_comp]
  right <- navbar$right %||% components[right_comp]

  if (pkg$bs_version == 3) {
    return(
      list(
        type = navbar$type %||% "default",
        left = render_navbar_links(left, depth = depth, bs_version = pkg$bs_version),
        right = render_navbar_links(right, depth = depth, bs_version = pkg$bs_version)
      )
    )
  }

  list(
    type = navbar$type %||% "light",
    bg = navbar$bg %||% "light",
    left = render_navbar_links(left, depth = depth, pkg$bs_version),
    right = render_navbar_links(right, depth = depth, pkg$bs_version)
  )
}

render_navbar_links <- function(x, depth = 0L, bs_version) {
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

  if (bs_version == 3) {
    return(rmarkdown::navbar_links_html(x))
  }

  bs4_navbar_links_html(x)

}

# Default navbar ----------------------------------------------------------

navbar_structure <- function() {
  print_yaml(navbar_structure_defaults())
}

navbar_structure_defaults <- function() {
  list(
    left = c("intro", "reference", "articles", "tutorials", "news"),
    right = "github"
  )
}

navbar_components <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  menu <- list()
  menu$reference <- menu_link("Reference", "reference/index.html")

  if (!is.null(pkg$tutorials)) {
    menu$tutorials <- menu("Tutorials",
      menu_links(pkg$tutorials$title, pkg$tutorials$file_out)
    )
  }
  menu$news <- navbar_news(pkg)

  menu$github <- switch(
    repo_type(pkg),
    github = menu_icon("github", repo_home(pkg), style = "fab"),
    gitlab = menu_icon("gitlab", repo_home(pkg), style = "fab"),
    NULL
  )

  menu <- c(menu, navbar_articles(pkg))

  print_yaml(menu)
}

navbar_articles <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  menu <- list()

  vignettes <- pkg$vignettes
  pkg_intro <- article_is_intro(vignettes$name, pkg$package)
  if (any(pkg_intro)) {
    intro <- vignettes[pkg_intro, , drop = FALSE]

    menu$intro <- menu_link("Get started", intro$file_out)
  }


  meta <- pkg$meta
  if (!has_name(meta, "articles")) {
    vignettes <- vignettes[!pkg_intro, , drop = FALSE]
    menu$articles <- menu("Articles", menu_links(vignettes$title, vignettes$file_out))
  } else {
    articles <- meta$articles

    navbar <- purrr::keep(articles, ~ has_name(.x, "navbar"))
    if (length(navbar) == 0) {
      # No articles to be included in navbar so just link to index
      menu$articles <- menu_link("Articles", "articles/index.html")
    } else {
      sections <- lapply(navbar, function(section) {
        vig <- pkg$vignettes[select_vignettes(section$contents, pkg$vignettes), , drop = FALSE]
        vig <- vig[vig$name != pkg$package, , drop = FALSE]
        c(
          if (!is.null(section$navbar)) list(menu_spacer(), menu_text(section$navbar)),
          menu_links(vig$title, vig$file_out)
        )
      })
      children <- unlist(sections, recursive = FALSE, use.names = FALSE)

      if (length(navbar) != length(articles)) {
        children <- c(children, list(menu_spacer(), menu_link("More...", "articles/index.html")))
      }
      menu$articles <- menu("Articles", children)
    }
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


# Testing helpers ---------------------------------------------------------
# Simulate minimal package structure so we can more easily test

pkg_navbar <- function(meta = NULL, vignettes = pkg_navbar_vignettes(),
                       github_url = NULL) {
  structure(
    list(
      package = "test",
      src_path = file_temp(),
      meta = meta,
      vignettes = vignettes,
      repo = list(url = list(home = github_url))
    ),
    class = "pkgdown"
  )
}

pkg_navbar_vignettes <- function(name = character(),
                                 title = NULL,
                                 file_out = NULL) {
  title <- title %||% paste0("Title ", name)
  file_out <- file_out %||% paste0(name, ".html")

  tibble::tibble(name = name, title = title, file_out)
}

bs4_navbar_links_html <- function(links) {
  as.character(bs4_navbar_links_tags(links))
}

#' @importFrom htmltools tags tagList
bs4_navbar_links_tags <- function(links, depth = 0L) {

  if (is.null(links)) {
    return(tagList())
  }

  # sub-menu
  is_submenu <- (depth > 0L)

  # function for links
  tackle_link <- function(x, is_submenu, depth) {

    if (!is.null(x$menu)) {

      if (is_submenu) {
        menu_class <- "dropdown-item"
        link_text <- bs4_navbar_link_text(x)
      } else {
        menu_class <- "nav-item dropdown"
        link_text <- bs4_navbar_link_text(x)
      }

      submenuLinks <- bs4_navbar_links_tags(x$menu, depth = depth + 1L)

      return(
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
      )

    }

    if (!is.null(x$text) && grepl("^\\s*-{3,}\\s*$", x$text)) {
      # divider
      return(tags$div(class = "dropdown-divider"))
    }

    if (!is.null(x$text) && is.null(x$href)) {
      # header
      return(tags$h6(class = "dropdown-header", `data-toc-skip` = NA, x$text))
    }

    # standard menu item
    textTags <- bs4_navbar_link_text(x)

    if (is_submenu) {
      return(tags$a(class = "dropdown-item", href = x$href, textTags))
    }

    tags$li(
      class = "nav-item",
      tags$a(class = "nav-link", href = x$href, textTags)
    )

  }

  tags <- lapply(links, tackle_link, is_submenu = is_submenu, depth = depth)
  tagList(tags)

}

bs4_navbar_link_text <- function(x, ...) {

  if (!is.null(x$icon)) {
    # find the iconset
    split <- strsplit(x$icon, "-")
    if (length(split[[1]]) > 1) {
      iconset <- split[[1]][[1]]
    }
    else {
      iconset <- ""
    }
    tagList(tags$span(class = paste(iconset, x$icon)), " ", x$text, ...)
  }
  else
    tagList(x$text, ...)
}
