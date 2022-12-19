#' Call hook
call_hook <- function(hook_name, ...) {
  # Get hooks from base::getHook
  hooks <- getHook(paste0("UserHook::pkgdown::", hook_name))
  if (!is.list(hooks)) {
    hooks <- list(hooks)
  }

  # Evaluate hooks
  purrr::map(hooks, function(fun) {
    fun(...)
  }) %>%
    invisible()
}
