#' Deploy a pkgdown site on Travis-CI to Github Pages
#'
#' @description
#' `r lifecycle::badge('superseded')`
#'
#' `deploy_site_github()` was designed to deploy your site from Travis CI,
#' which we no longer recommend, so this function is deprecated. There are
#' two replacements:
#'
#' * [usethis::use_pkgdown_github_pages()] will setup a GitHub action to
#'   automatically build and deploy your package website to GitHub pages.
#'
#' * [deploy_to_branch()] can be called locally to build and deploy your
#'   website to any desired branch.
#'
#' @inheritParams build_site
#' @param install Optionally, opt-out of automatic installation. This is
#'   necessary if the package you're documenting is a dependency of pkgdown
#' @param tarball The location of the built package tarball. The default Travis
#'   configuration for R packages sets `PKG_TARBALL` to this path.
#' @param ssh_id The private id to use, a base64 encoded content of the private
#'   pem file. This should _not_ be your personal private key. Instead create a
#'   new keypair specifically for deploying the site. The easiest way is to use
#'   `travis::use_travis_deploy()`.
#' @param commit_message The commit message to be used for the commit.
#' @param clean Clean all files from old site.
#' @param verbose Print verbose output
#' @param ... Additional arguments passed to [build_site()].
#' @param host The GitHub host url.
#' @param repo_slug The `user/repo` slug for the repository.
#' @export
#' @keywords internal
deploy_site_github <- function(
  pkg = ".",
  install = TRUE,
  tarball = Sys.getenv("PKG_TARBALL", ""),
  ssh_id = Sys.getenv("id_rsa", ""),
  commit_message = construct_commit_message(pkg),
  clean = FALSE,
  verbose = FALSE,
  host = "github.com",
  ...,
  repo_slug = Sys.getenv("TRAVIS_REPO_SLUG", "")
) {
  rlang::check_installed("openssl")
  if (!nzchar(tarball)) {
    cli::cli_abort(
      "No built tarball detected, please provide the location of one with {.var tarball}",
      call = caller_env()
    )
  }

  if (!nzchar(ssh_id)) {
    cli::cli_abort(
      "No deploy key found, please setup with {.fn travis::use_travis_deploy}",
      call = caller_env()
    )
  }

  if (!nzchar(repo_slug)) {
    cli::cli_abort(
      "No repo detected, please supply one with {.var repo_slug}",
      call = caller_env()
    )
  }

  cli::cli_alert("Deploying site to GitHub")
  if (install) {
    cli::cli_inform("Installing package")
    callr::rcmd("INSTALL", tarball, show = verbose, fail_on_status = TRUE)
  }

  ssh_id_file <- "~/.ssh/id_rsa"
  cli::cli_inform("Setting up SSH id")
  cli::cli_inform("Copying private key to {.file ssh_id_file}")
  write_lines(rawToChar(openssl::base64_decode(ssh_id)), ssh_id_file)
  cli::cli_inform("Setting private key permissions to 0600")
  file_chmod(ssh_id_file, "0600")

  cli::cli_inform("Setting remote to use the ssh url")

  git("remote", "set-url", "origin", sprintf("git@%s:%s.git", host, repo_slug))

  deploy_to_branch(
    pkg,
    commit_message = commit_message,
    clean = clean,
    branch = "gh-pages",
    ...
  )

  cli::cli_inform(c(v = "Deploy completed"))
}

#' Build and deploy a site locally
#'
#' Assumes that you're in a git clone of the project, and the package is
#' already installed. Use [usethis::use_pkgdown_github_pages()] to automate
#' this process using GitHub actions.
#'
#' @param branch The git branch to deploy to
#' @param remote The git remote to deploy to
#' @param github_pages Is this a GitHub pages deploy. If `TRUE`, adds a `CNAME`
#'   file for custom domain name support, and a `.nojekyll` file to suppress
#'   jekyll rendering.
#' @param ... Additional arguments passed to [build_site()].
#' @param subdir The sub-directory where the site should be built on the branch.
#'   This argument can be used to support a number of site configurations.
#'   For example, you could build version-specific documentation by setting
#'   `subdir = "v1.2.3"`; `deploy_to_branch()` will build and deploy the
#'   package documentation in the `v.1.2.3/` directory of your site.
#' @inheritParams build_site
#' @inheritParams deploy_site_github
#' @export
deploy_to_branch <- function(
  pkg = ".",
  commit_message = construct_commit_message(pkg),
  clean = TRUE,
  branch = "gh-pages",
  remote = "origin",
  github_pages = (branch == "gh-pages"),
  ...,
  subdir = NULL
) {
  dest_dir <- dir_create(file_temp())
  on.exit(dir_delete(dest_dir))

  if (!git_has_remote_branch(remote, branch)) {
    old_branch <- git_current_branch()

    # If no remote branch, we need to create it
    git("checkout", "--orphan", branch)
    git("rm", "-rf", "--quiet", ".")
    git(
      "commit",
      "--allow-empty",
      "-m",
      sprintf("Initializing %s branch", branch)
    )
    git("push", remote, paste0("HEAD:", branch))

    # checkout the previous branch
    git("checkout", old_branch)
  }

  # Explicitly set the branches tracked by the origin remote.
  # Needed if we are using a shallow clone, such as on travis-CI
  git("remote", "set-branches", "--add", remote, branch)

  git("fetch", remote, branch)

  github_worktree_add(dest_dir, remote, branch)
  on.exit(github_worktree_remove(dest_dir), add = TRUE)

  site_dest_dir <-
    if (!is.null(subdir)) {
      dir_create(path(dest_dir, subdir))
    } else {
      dest_dir
    }

  pkg <- as_pkgdown(pkg, override = list(destination = site_dest_dir))

  if (!is.null(subdir) && !is.null(pkg$meta$url)) {
    pkg$meta$url <- path(pkg$meta$url, subdir)
  }

  build_site_github_pages(pkg, ..., clean = clean)

  github_push(dest_dir, commit_message, remote, branch)

  invisible()
}

git_has_remote_branch <- function(remote, branch) {
  has_remote_branch <- git(
    "ls-remote",
    "--quiet",
    "--exit-code",
    remote,
    branch,
    echo = FALSE,
    echo_cmd = FALSE,
    error_on_status = FALSE
  )$status ==
    0
}

git_current_branch <- function() {
  branch <- git(
    "rev-parse",
    "--abbrev-ref",
    "HEAD",
    echo = FALSE,
    echo_cmd = FALSE
  )$stdout
  sub("\n$", "", branch)
}

github_worktree_add <- function(dir, remote, branch) {
  cli::cli_inform("Adding worktree")
  git(
    "worktree",
    "add",
    "--track",
    "-B",
    branch,
    dir,
    paste0(remote, "/", branch)
  )
}

github_worktree_remove <- function(dir) {
  cli::cli_inform("Removing worktree")
  git("worktree", "remove", dir)
}

github_push <- function(dir, commit_message, remote, branch) {
  # force execution before changing working directory
  force(commit_message)

  cli::cli_inform("Commiting updated site")

  withr::with_dir(dir, {
    git("add", "-A", ".")
    git("commit", "--allow-empty", "-m", commit_message)

    cli::cli_alert("Deploying to GitHub Pages")
    git("remote", "-v")
    git("push", "--force", remote, paste0("HEAD:", branch))
  })
}

git <- function(..., echo_cmd = TRUE, echo = TRUE, error_on_status = TRUE) {
  callr::run(
    "git",
    c(...),
    echo_cmd = echo_cmd,
    echo = echo,
    error_on_status = error_on_status
  )
}

construct_commit_message <- function(pkg = ".", commit = ci_commit_sha()) {
  pkg <- as_pkgdown(pkg)
  cli::format_inline(
    "Built site for {pkg$package}@{pkg$version}: {substr(commit, 1, 7)}"
  )
}

ci_commit_sha <- function() {
  env_vars <- c(
    # https://docs.travis-ci.com/user/environment-variables/#default-environment-variables
    "TRAVIS_COMMIT",
    # https://help.github.com/en/actions/configuring-and-managing-workflows/using-environment-variables#default-environment-variables
    "GITHUB_SHA"
  )

  for (var in env_vars) {
    commit_sha <- Sys.getenv(var, "")
    if (commit_sha != "") return(commit_sha)
  }

  ""
}
