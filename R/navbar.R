data_navbar <- function(pkg = ".", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  navbar <- purrr::pluck(pkg, "meta", "navbar")

  style <- navbar_style(
    navbar = navbar,
    theme = get_bootswatch_theme(pkg),
    bs_version = pkg$bs_version
  )

  links <- navbar_links(pkg, depth = depth)

  c(style, links)
}

# Default navbar ----------------------------------------------------------

navbar_style <- function(navbar = list(), theme = "_default", bs_version = 3) {
  if (bs_version == 3) {
    list(type = navbar$type %||% "default")
  } else {
    # bg is usually light, dark, or primary, but can use any .bg-*
    bg <- navbar$bg %||% bootswatch_bg[[theme]]
    type <- navbar$type %||% if (bg == "light") "light" else "dark"

    list(bg = bg, type = type)
  }
}

navbar_structure <- function() {
  print_yaml(list(
    left = c("intro", "reference", "articles", "tutorials", "news"),
    right = "github"
  ))
}

navbar_links <- function(pkg, depth = 0L) {
  navbar <- purrr::pluck(pkg, "meta", "navbar")

  # Combine default components with user supplied
  components <- navbar_components(pkg)
  components_meta <- navbar$components %||% list()
  components[names(components_meta)] <- components_meta
  components <- purrr::compact(components)

  # Combine default structure with user supplied
  pkg$meta$navbar$structure <- modify_list(navbar_structure(), pkg$meta$navbar$structure)
  right_comp <- intersect(
    yaml_character(pkg, c("navbar", "structure", "right")),
    names(components)
  )
  left_comp <- intersect(
    yaml_character(pkg, c("navbar", "structure", "left")),
    names(components)
  )

  # Backward compatibility
  left <- navbar$left %||% components[left_comp]
  right <- navbar$right %||% components[right_comp]

  list(
    left = render_navbar_links(left, depth = depth, bs_version = pkg$bs_version),
    right = render_navbar_links(right, depth = depth, bs_version = pkg$bs_version)
  )
}

render_navbar_links <- function(x, depth = 0L, bs_version = 3) {
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
    rmarkdown::navbar_links_html(x)
  } else {
    bs4_navbar_links_html(x)
  }
}

# Components --------------------------------------------------------------

navbar_components <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  menu <- list()
  menu$reference <- menu_link(tr_("Reference"), "reference/index.html")

  if (!is.null(pkg$tutorials)) {
    menu$tutorials <- menu(tr_("Tutorials"),
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

    menu$intro <- menu_link(tr_("Get started"), intro$file_out)
  }

  meta <- pkg$meta
  if (!has_name(meta, "articles")) {
    vignettes <- vignettes[!pkg_intro, , drop = FALSE]
    menu$articles <- menu(tr_("Articles"), menu_links(vignettes$title, vignettes$file_out))
  } else {
    articles <- meta$articles

    navbar <- purrr::keep(articles, ~ has_name(.x, "navbar"))
    if (length(navbar) == 0) {
      # No articles to be included in navbar so just link to index
      menu$articles <- menu_link(tr_("Articles"), "articles/index.html")
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
        children <- c(children, list(menu_spacer(), menu_link(tr_("More articles..."), "articles/index.html")))
      }
      menu$articles <- menu(tr_("Articles"), children)
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
  list(icon = paste0(style, " fa-", icon, " fa-lg"), href = href, "aria-label" = icon)
}
menu_text <- function(text) {
  list(text = text)
}
menu_spacer <- function() {
  menu_text("---------")
}

bs4_navbar_links_html <- function(links) {
  as.character(bs4_navbar_links_tags(links), options = character())
}

bs4_navbar_links_tags <- function(links, depth = 0L) {
  rlang::check_installed("htmltools")

  if (is.null(links)) {
    return(htmltools::tagList())
  }

  # sub-menu
  is_submenu <- (depth > 0L)

  # function for links
  tackle_link <- function(x, index, is_submenu, depth) {

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
        htmltools::tags$li(
          class = menu_class,
          htmltools::tags$a(
            href = "#", class = "nav-link dropdown-toggle",
            `data-bs-toggle` = "dropdown", role = "button",
            `aria-expanded` = "false", `aria-haspopup` = "true",
            link_text,
            id = paste0("dropdown-", make_slug(link_text)),
          "aria-label" = x$`aria-label` %||% NULL
          ),
          htmltools::tags$div(
            class = "dropdown-menu",
            `aria-labelledby` = paste0("dropdown-", make_slug(link_text)),
            submenuLinks
          )
        )
      )

    }

    if (!is.null(x$text) && grepl("^\\s*-{3,}\\s*$", x$text)) {

      if (index == 1) {
        return(htmltools::tagList())
      } else {
        return(htmltools::tags$div(class = "dropdown-divider"))
      }
    }

    if (!is.null(x$text) && is.null(x$href)) {
      # header
      return(htmltools::tags$h6(class = "dropdown-header", `data-toc-skip` = NA, x$text))
    }

    # standard menu item
    textTags <- bs4_navbar_link_text(x)

    if (is_submenu) {
      return(
        htmltools::tags$a(
          class = "dropdown-item",
          href = x$href,
          target = x$target,
          textTags,
          "aria-label" = x$`aria-label` %||% NULL
        )
      )
    }

    htmltools::tags$li(
      class = "nav-item",
      htmltools::tags$a(
        class = "nav-link",
        href = x$href,
        target = x$target,
        textTags,
        "aria-label" = x$`aria-label` %||% NULL
      )
    )

  }

  tags <- purrr::map2(links, seq_along(links), tackle_link, is_submenu = is_submenu, depth = depth)
  htmltools::tagList(tags)

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
    htmltools::tagList(htmltools::tags$span(class = paste(iconset, x$icon)), " ", x$text, ...)
  }
  else
    htmltools::tagList(x$text, ...)
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


# bootswatch defaults -----------------------------------------------------

# Scraped from bootswatch preivews, see code in
# <https://github.com/r-lib/pkgdown/issues/1758>
bootswatch_bg <- c(
  "_default" = "light",
  cerulean = "primary",
  cosmo = "primary",
  cyborg = "dark",
  darkly = "primary",
  flatly = "primary",
  journal = "light",
  litera = "light",
  lumen = "light",
  lux = "light",
  materia = "primary",
  minty = "primary",
  morph = "primary",
  pulse = "primary",
  quartz = "primary",
  sandstone = "primary",
  simplex = "light",
  sketchy = "light",
  slate = "primary",
  solar = "dark",
  spacelab = "light",
  superhero = "dark",
  united = "primary",
  vapor = "primary",
  yeti = "primary",
  zephyr = "primary"
)
