\name{build_package}
\alias{build_package}
\alias{staticdocs-package}
\title{Build complete static documentation for a package.}
\usage{
  build_package(package, base_path = NULL, examples = NULL)
}
\arguments{
  \item{package}{path to source version of package.  See
  \code{\link[devtools]{as.package}} for details on how
  paths and package names are resolved.}

  \item{base_path}{root directory in which to create
  documentation}

  \item{examples}{include examples or not?  Examples are
  particularly slow to render because all code must be run,
  so turning them off makes it easier to tweak templates
  etc.}
}
\description{
  Currently, knitr builds documentation for:
}
\details{
  \itemize{ \item Rd files.  Files \item Demos. Must be
  listed in \file{demos/00index}.  \item Vignettes. }
}

