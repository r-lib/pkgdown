section_init <- function(pkg,
                         subdir = NULL,
                         override = list(),
                         .frame = parent.frame()) {
  rstudio_save_all()
  pkg <- as_pkgdown(pkg, override = override)
  
  if (!dir_exists(pkg$dst_path)) {
    init_site(pkg)
  } else if (is_non_pkgdown_site(pkg$dst_path)) {
    cli::cli_abort(c(
      "{.file {pkg$dst_path}} is non-empty and not built by pkgdown",
      "!" = "Make sure it contains no important information \\
             and use {.run pkgdown::clean_site()} to delete its contents."
      )
    )
  }
 
  if (is.null(subdir)) {
    depth <- 0
  } else {
    depth <- 1
    dir_create(path(pkg$dst_path, subdir))
  }

  local_envvar_pkgdown(pkg, .frame)
  local_options_link(pkg, depth = depth, .frame = .frame)

  pkg
}

is_non_pkgdown_site <- function(dst_path) {
  top_level <- dir_ls(dst_path)
  top_level <- top_level[!path_file(top_level) %in% c("CNAME", "dev", "deps")]

  length(top_level) >= 1 && !"pkgdown.yml" %in% path_file(top_level)
}

local_options_link <- function(pkg, depth, .frame = parent.frame()) {
  article_index <- article_index(pkg)
  Rdname <- get_rdname(pkg$topics)
  topic_index <- unlist(invert_index(set_names(pkg$topics$alias, Rdname)))

  withr::local_options(
    list(
      downlit.package = pkg$package,
      downlit.article_index = article_index,
      downlit.topic_index = topic_index,
      downlit.article_path = paste0(up_path(depth), "articles/"),
      downlit.topic_path = paste0(up_path(depth), "reference/")
    ),
    .local_envir = .frame
  )
}

local_context_eval <- function(
                               figures = NULL,
                               src_path = getwd(),
                               sexpr_env = child_env(globalenv()),
                               .frame = parent.frame()) {
  context_set_scoped("figures", figures, scope = .frame)
  context_set_scoped("src_path", src_path, scope = .frame)
  context_set_scoped("sexpr_env", sexpr_env, scope = .frame)
}

# Manage current topic index ----------------------------------------------------

context <- new_environment()
context$packages <- character()

context_set <- function(name, value) {
  old <- if (env_has(context, name)) env_get(context, name)

  if (is.null(value)) {
    if (env_has(context, name)) {
      env_unbind(context, name)
    }
  } else {
    env_bind(context, !!name := value)
  }
  invisible(old)
}

context_get <- function(name) {
  if (env_has(context, name)) {
    env_get(context, name)
  } else {
    cli::cli_abort("Context {.str name} has not been initialised")
  }
}

context_set_scoped <- function(name, value, scope = parent.frame()) {
  old <- context_set(name, value)
  withr::defer(context_set(name, old), envir = scope)
}

article_index <- function(pkg) {
  set_names(
    path_rel(pkg$vignettes$file_out, "articles"),
    pkg$vignettes$name
  )
}
