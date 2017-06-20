
# Manage current topic index ----------------------------------------------------

context <- new_environment()

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
  defer(context_set(name, old), scope = scope)
}

scoped_package_context <- function(package,
                                   topic_index = NULL,
                                   scope = parent.frame()) {
  topic_index <- topic_index %||% topic_index(package)

  context_set_scoped("package", package, scope = scope)
  context_set_scoped("topic_index", topic_index, scope = scope)
}
scoped_file_context <- function(rdname = "",
                                depth = 0L,
                                packages = character(),
                                scope = parent.frame()) {
  context_set_scoped("rdname", rdname, scope = scope)
  context_set_scoped("depth", depth, scope = scope)
  context_set_scoped("packages", packages, scope = scope)
}

# defer helper ------------------------------------------------------------

defer <- function(expr, scope = parent.frame()) {
  expr <- enquo(expr)

  call <- expr(on.exit(rlang::eval_tidy(!!expr), add = TRUE))
  eval_bare(call, scope)

  invisible()
}
