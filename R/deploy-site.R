#' Deploy a pkgdown site on Travis-CI to Github Pages
#'
#' `deploy_site_github()` sets up your SSH keys for deployment, builds the
#' site with [build_site()], commits the site to the `gh-pages` branch and then pushes
#' the results back to GitHub. `deploy_site_github()` is meant only to be used
#' by the CI system on Travis, it should not be called locally. See 'Setup' for
#' details on setting up your repository to use this.
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
#' website](https://ropenscilabs.github.io/travis/) for more details.
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
#'   necessary if the package you're document is a dependency of pkgdown
#' @param tarball The location of the built package tarball. The default Travis
#'   configuration for R packages sets `PKG_TARBALL` to this path.
#' @param ssh_id The private id to use, a base64 encoded content of the private
#'   pem file. This should _not_ be your personal private key. Instead create a
#'   new keypair specifically for deploying the site. The easiest way is to use
#'   `travis::use_travis_deploy()`.
#' @param repo_slug The `user/repo` slug for the repository.
#' @param commit_message The commit message to be used for the commit.
#' @param verbose Print verbose output
#' @param ... Additional arguments passed to [build_site()].
#' @export
deploy_site_github <- function(
  pkg = ".",
  install = TRUE,
  tarball = Sys.getenv("PKG_TARBALL", ""),
  ssh_id = Sys.getenv("id_rsa", ""),
  repo_slug = Sys.getenv("TRAVIS_REPO_SLUG", ""),
  commit_message = construct_commit_message(pkg),
  verbose = FALSE,
  ...) {

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

  deploy_local(pkg, repo_slug = repo_slug, commit_message = commit_message, ...)

  rule("Deploy completed", line = 2)
}

deploy_local <- function(
                         pkg = ".",
                         repo_slug = NULL,
                         commit_message = construct_commit_message(pkg),
                         ...
                         ) {

  dest_dir <- fs::dir_create(fs::file_temp())
  on.exit(fs::dir_delete(dest_dir))

  pkg <- as_pkgdown(pkg)
  if (is.null(repo_slug)) {
    gh <- rematch2::re_match(pkg$github_url, github_url_rx())
    repo_slug <- paste0(gh$owner, "/", gh$repo)
  }

  github_clone(dest_dir, repo_slug)
  build_site(".",
    override = list(destination = dest_dir),
    devel = FALSE,
    preview = FALSE,
    install = FALSE,
    ...
  )
  github_push(dest_dir, commit_message)

  invisible()
}

github_clone <- function(dir, repo_slug) {
  remote_url <- sprintf("git@github.com:%s.git", repo_slug)
  rule("Cloning existing site", line = 1)
  git("clone",
    "--single-branch", "-b", "gh-pages",
    "--depth", "1",
    remote_url,
    dir
  )
}

github_push <- function(dir, commit_message) {
  # force execution before changing working directory
  force(commit_message)

  rule("Commiting updated site", line = 1)

  with_dir(dir, {
    git("add", "-A", ".")
    git("commit", "--allow-empty", "-m", commit_message)

    rule("Deploying to GitHub Pages", line = 1)
    git("remote", "-v")
    git("push", "--force", "origin", "HEAD:gh-pages")
  })
}

git <- function(...) {
  processx::run("git", c(...), echo_cmd = TRUE, echo = TRUE)
}

construct_commit_message <- function(pkg, commit = Sys.getenv("TRAVIS_COMMIT")) {
  pkg <- as_pkgdown(pkg)

  sprintf("Built site for %s: %s@%s", pkg$package, pkg$version, substr(commit, 1, 7))
}
