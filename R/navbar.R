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
    type = navbar$type %||% "default",
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
  rmarkdown::navbar_links_html(x)
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

  if (!is.null(pkg$tutorials)) {
    menu$tutorials <- menu("Tutorials",
      menu_links(pkg$tutorials$title, pkg$tutorials$file_out)
    )
  }
  menu$news <- navbar_news(pkg)

  if (!is.null(pkg$github_url)) {
    menu$github <- menu_icon("github", pkg$github_url, style = "fab")
  }

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

  if (!is.null(pkg$repo$url$home)) {
    menu$github <- menu_icon("github", repo_home(pkg), style = "fab")
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

pkg_navbar <- function(
                           meta = NULL,
                           vignettes = pkg_navbar_vignettes(),
                           github_url = NULL) {
  structure(
    list(
      package = "test",
      src_path = file_temp(),
      meta = meta,
      vignettes = vignettes,
      github_url = github_url
    ),
    class = "pkgdown"
  )
}

pkg_navbar_vignettes <- function(
                                 name = character(),
                                 title = NULL,
                                 file_out = NULL) {
  title <- title %||% paste0("Title ", name)
  file_out <- file_out %||% paste0(name, ".html")

  tibble::tibble(name = name, title = title, file_out)
}
