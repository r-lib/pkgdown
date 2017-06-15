
# Manage current topic index ----------------------------------------------------

cache <- new_environment()

cur_topic_index_set <- function(index) {
  old <- cur_topic_index_get()
  if (is.null(index) && env_has(cached,)) {
    env_unbind(cache, "topic_index")
  } else {
    env_bind(cache, topic_index = index)
  }
  invisible(old)
}
cur_topic_index_get <- function(check = FALSE) {
  if (env_has(cache, "topic_index")) {
    env_get(cache, "topic_index")
  } else {
    if (check) {
      abort("Default topic index has not been initialised")
    }
    NULL
  }
}
