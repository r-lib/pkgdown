meta_development <- function(pkg, call = caller_env()) {
  config_pluck_list(pkg, "development", call = call)

  mode <- dev_mode(pkg, call = call)

  destination <- config_pluck_string(
    pkg,
    "development.destination",
    default = "dev",
    call = call
  )
  version_label <- config_pluck_string(
    pkg,
    "development.version_label",
    call = call
  )
  if (is.null(version_label)) {
    if (mode %in% c("release", "default")) {
      version_label <- if (pkg$bs_version == 3) "default" else "muted"
    } else {
      version_label <- "danger"
    }
  }
  in_dev <- mode == "devel"

  list(
    destination = destination,
    mode = mode,
    version_label = version_label,
    in_dev = in_dev,
    prefix = if (in_dev) paste0(destination, "/") else ""
  )
}

dev_mode <- function(pkg, call = caller_env()) {
  mode <- Sys.getenv("PKGDOWN_DEV_MODE")
  if (identical(mode, "")) {
    mode <- config_pluck_string(
      pkg,
      "development.mode",
      default = "default",
      call = call
    )
  }

  if (mode == "auto") {
    mode <- dev_mode_auto(pkg$version)
  } else {
    valid_mode <- c("auto", "default", "release", "devel", "unreleased")
    if (!mode %in% valid_mode) {
      msg <- "{.field development.mode} must be one of {.or {valid_mode}}, not {mode}."
      config_abort(pkg, msg, call = call)
    }
  }

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

# Called in render_page() so that LANG env var set up
version_tooltip <- function(mode) {
  switch(
    mode,
    default = "",
    release = tr_("Released version"),
    devel = tr_("In-development version"),
    unreleased = tr_("Unreleased version")
  )
}
