#' Deploy a pkgdown site on Travis-CI to Github Pages
#'
#' `deploy_site_github()` sets up your SSH keys for deployment, builds the
#' site with [build_site()], commits the site to the `gh-pages` branch and then pushes
#' the results back to GitHub. `deploy_site_github()` is meant only to be used
#' by the CI system on Travis, it should not be called locally.
#' [deploy_to_branch()] can be used to deploy a site directly to GitHub Pages
#' locally. See 'Setup' for details on setting up your repository to use this.
#'
#' @section Setup:
#' For a quick setup, you can use [usethis::use_pkgdown_travis()]. It  will help you
#' with the following detailed steps.
#'
#' * Add the following to your `.travis.yml` file.
#'
#'     ```
#'     before_cache: Rscript -e 'remotes::install_cran("pkgdown")'
#'     deploy:
#'       provider: script
#'       script: Rscript -e 'pkgdown::deploy_site_github()'
#'       skip_cleanup: true
#'     ```
#'
#' * Then you will need to setup your deployment keys. The easiest way is to call
#' `travis::use_travis_deploy()`. This will generate and push the necessary
#' keys to your GitHub and Travis accounts. See the [travis package
#' website](https://docs.ropensci.org/travis/index.html) for more details.
#'
#' * Next, make sure that a gh-pages branch exists. The simplest way to do
#' so is to run the following git commands locally:
#'
#'     ```
#'     git checkout --orphan gh-pages
#'     git rm -rf .
#'     git commit --allow-empty -m 'Initial gh-pages commit'
#'     git push origin gh-pages
#'     git checkout master
#'     ```
#'
#'     We recommend doing this outside of RStudio (with the project closed) as
#'     from RStudio's perspective you end up deleting all the files and then
#'     re-creating them.
#'
#' *  If you're using a custom CNAME, make sure you have set the `url` in
#' `_pkgdown.yaml`:
#'
#'    ```yaml
#'    url: http://pkgdown.r-lib.org
#'    ```
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
  repo_slug = Sys.getenv("TRAVIS_REPO_SLUG", "")) {

  if (!nzchar(tarball)) {
    stop("No built tarball detected, please provide the location of one with `tarball`", call. = FALSE)
  }

  if (!nzchar(ssh_id)) {
    stop("No deploy key found, please setup with `travis::use_travis_deploy()`", call. = FALSE)
  }

  if (!nzchar(repo_slug)) {
    stop("No repo detected, please supply one with `repo_slug`", call. = FALSE)
  }

  rule("Deploying site", line = 2)
  if (install) {
    rule("Installing package", line = 1)
    callr::rcmd("INSTALL", tarball, show = verbose, fail_on_status = TRUE)
  }

  ssh_id_file <- "~/.ssh/id_rsa"
  rule("Setting up SSH id", line = 1)
  cat_line("Copying private key to: ", ssh_id_file)
  write_lines(rawToChar(openssl::base64_decode(ssh_id)), ssh_id_file)
  cat_line("Setting private key permissions to 0600")
  fs::file_chmod(ssh_id_file, "0600")

  cat_line("Setting remote to use the ssh url")

  git("remote", "set-url", "origin", sprintf("git@%s:%s.git", host, repo_slug))

  deploy_to_branch(
    pkg,
    commit_message = commit_message,
    clean = clean,
    branch = "gh-pages",
    ...
  )

  rule("Deploy completed", line = 2)
}

#' Build and deploy a site locally
#'
#' Assumes that you're in a git clone of the project, and the package is
#' already installed.
#'
#' @param branch The git branch to deploy to
#' @param remote The git remote to deploy to
#' @param github_pages Is this a GitHub pages deploy. If `TRUE`, adds a `CNAME`
#'   file for custom domain name support, and a `.nojekyll` file to suppress
#'   jekyll rendering.
#' @param ... Additional arguments passed to [build_site()].
#' @inheritParams build_site
#' @inheritParams deploy_site_github
#' @export
deploy_to_branch <- function(pkg = ".",
                         commit_message = construct_commit_message(pkg),
                         clean = FALSE,
                         branch = "gh-pages",
                         remote = "origin",
                         github_pages = (branch == "gh-pages"),
                         ...) {
  dest_dir <- fs::dir_create(fs::file_temp())
  on.exit(fs::dir_delete(dest_dir))

  if (!git_has_remote_branch(remote, branch)) {
    old_branch <- git_current_branch()

    # If no remote branch, we need to create it
    git("checkout", "--orphan", branch)
    git("rm", "-rf", "--quiet", ".")
    git("commit", "--allow-empty", "-m", sprintf("Initializing %s branch", branch))
    git("push", remote, paste0("HEAD:", branch))

    # checkout the previous branch
    git("checkout", old_branch)
  }

  # Explicitly set the branches tracked by the origin remote.
  # Needed if we are using a shallow clone, such as on travis-CI
  git("remote", "set-branches", remote, branch)

  git("fetch", remote, branch)

  github_worktree_add(dest_dir, remote, branch)
  on.exit(github_worktree_remove(dest_dir), add = TRUE)

  pkg <- as_pkgdown(pkg, override = list(destination = dest_dir))

  if (clean) {
    rule("Cleaning files from old site", line = 1)
    clean_site(pkg)
  }

  build_site(pkg, devel = FALSE, preview = FALSE, install = FALSE, ...)
  if (github_pages) {
    build_github_pages(pkg)
  }

  github_push(dest_dir, commit_message, remote, branch)

  invisible()
}


git_has_remote_branch <- function(remote, branch) {
  has_remote_branch <- git("ls-remote", "--quiet", "--exit-code", remote, branch, echo = FALSE, echo_cmd = FALSE, error_on_status = FALSE)$status == 0
}
git_current_branch <- function() {
  branch <- git("rev-parse", "--abbrev-ref", "HEAD", echo = FALSE, echo_cmd = FALSE)$stdout
  sub("\n$", "", branch)
}

github_worktree_add <- function(dir, remote, branch) {
  rule("Adding worktree", line = 1)
  git("worktree",
    "add",
    "--track", "-B", branch,
    dir,
    paste0(remote, "/", branch)
  )
}

github_worktree_remove <- function(dir) {
  rule("Removing worktree", line = 1)
  git("worktree", "remove", dir)
}

github_push <- function(dir, commit_message, remote, branch) {
  # force execution before changing working directory
  force(commit_message)

  rule("Commiting updated site", line = 1)

  with_dir(dir, {
    git("add", "-A", ".")
    git("commit", "--allow-empty", "-m", commit_message)

    rule("Deploying to GitHub Pages", line = 1)
    git("remote", "-v")
    git("push", "--force", remote, paste0("HEAD:", branch))
  })
}

git <- function(..., echo_cmd = TRUE, echo = TRUE, error_on_status = TRUE) {
  processx::run("git", c(...), echo_cmd = echo_cmd, echo = echo, error_on_status = error_on_status)
}

construct_commit_message <- function(pkg, commit = ci_commit_sha()) {
  pkg <- as_pkgdown(pkg)

  sprintf("Built site for %s: %s@%s", pkg$package, pkg$version, substr(commit, 1, 7))
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
    if (commit_sha != "")
      return(commit_sha)
  }

  ""
}
