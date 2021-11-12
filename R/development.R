meta_development <- function(meta, version, bs_version = 3) {
  # Need to re-bind locales here for translation
  local_envvar_pkgdown(meta)
  dir <- system.file("po", package = "pkgdown")
  bindtextdomain("R-pkgdown", dir)

  development <- purrr::pluck(meta, "development", .default = list())

  destination <- purrr::pluck(development, "destination", .default = "dev")

  mode <- dev_mode(version, development)

  version_label <- purrr::pluck(development, "version_label")
  if (is.null(version_label)) {
    if (mode %in% c("release", "default")) {
      version_label <- if (bs_version == 3) "default" else "muted"
    } else {
      version_label <- "danger"
    }
  }
  version_tooltip <- purrr::pluck(development, "version_tooltip")
  if (is.null(version_tooltip)) {
    version_tooltip <- switch(mode,
      default = "",
      release = tr_("Released version"),
      devel = tr_("In-development version"),
      unreleased = tr_("Unreleased version")
    )
  }

  in_dev <- mode == "devel"

  list(
    destination = destination,
    mode = mode,
    version_label = version_label,
    version_tooltip = version_tooltip,
    in_dev = in_dev
  )
}

dev_mode <- function(version, development) {
  mode <- Sys.getenv("PKGDOWN_DEV_MODE")
  if (identical(mode, "")) {
    mode <- purrr::pluck(development, "mode", .default = "default")
  }

  if (mode == "auto") {
    mode <- dev_mode_auto(version)
  }
  check_mode(mode)

  mode
}

dev_mode_auto <- function(version) {
  version <- unclass(package_version(version))[[1]]

  if (length(version) < 3) {
    "release"
  } else if (length(version) == 3) {
    if (version[3] >= 9000) {
      "devel"
    } else {
      "release"
    }
  } else if (identical(version[1:3], c(0L, 0L, 0L))) {
    "unreleased"
  } else {
    "devel"
  }
}

check_mode <- function(mode) {
  valid_mode <- c("auto", "default", "release", "devel", "unreleased")
  if (!mode %in% valid_mode) {
    abort(paste0(
      "`development.mode` in `_pkgdown.yml` must be one of ",
      paste(valid_mode, collapse = ", ")
    ))
  }
}
