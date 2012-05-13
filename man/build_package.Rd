\name{build_package}
\alias{build_package}
\alias{staticdocs-package}
\title{Build complete static documentation for a package.}
\usage{
  build_package(package, base_path = NULL, examples = NULL)
}
\arguments{
  \item{package}{name of package (as character string) to
  create documentation for}

  \item{base_path}{root directory in which to create
  documentation}

  \item{examples}{include examples or not?  Examples are
  particularly slow to render because all code must be run,
  so turning them off makes it easier to tweak templates
  etc.}
}
\description{
  Build complete static documentation for a package.
}

