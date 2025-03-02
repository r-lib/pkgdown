# Set various env vars (copied from tools::texi2dvi) to ensure that
# latex can find bib and style files in the right places
local_texi2dvi_envvars <- function(input_path, env = caller_env()) {
  withr::local_envvar(
    BSTINPUTS = bst_paths(input_path),
    TEXINPUTS = tex_paths(input_path),
    BIBINPUTS = bib_paths(input_path),
    .local_envir = env
  )
}

bst_paths <- function(path) {
  paths <- c(
    Sys.getenv("BSTINPUTS"),
    path_dir(path),
    path(R.home("share"), "texmf", "bibtex", "bst")
  )
  paste(paths, collapse = .Platform$path.sep)
}
tex_paths <- function(path) {
  paths <- c(
    Sys.getenv("TEXINPUTS"),
    path_dir(path),
    path(R.home("share"), "texmf", "tex", "latex")
  )
  paste(paths, collapse = .Platform$path.sep)
}
bib_paths <- function(path) {
  paths <- c(
    Sys.getenv("BIBINPUTS"),
    tex_paths(path)
  )
  paste(paths, collapse = .Platform$path.sep)
}
