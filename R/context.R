section_init <- function(pkg, depth, override = list(), .frame = parent.frame()) {
  pkg <- as_pkgdown(pkg, override = override)

  rstudio_save_all()
  local_envvar_pkgdown()
  local_options_link(pkg, depth = depth)

  pkg
}

local_options_link <- function(pkg, depth, .frame = parent.frame()) {
  article_index <- set_names(path_file(pkg$vignettes$file_out), pkg$vignettes$name)
  topic_index <- invert_index(set_names(pkg$topics$alias, pkg$topics$name))

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
    abort(paste0("Context `", name, "` has not been initialised"))
  }
}

context_set_scoped <- function(name, value, scope = parent.frame()) {
  old <- context_set(name, value)
  withr::defer(context_set(name, old), envir = scope)
}
