\name{build_vignettes}
\alias{build_vignettes}
\title{List all package vignettes.}
\usage{
  build_vignettes(package, base_path)
}
\arguments{
  \item{package}{name of package (as character string) to
  create documentation for}

  \item{base_path}{root directory in which to create
  documentation}
}
\value{
  a list, with one element for each vignette containing the
  vignette title and file name.
}
\description{
  Copies all vignettes and returns data structure suitable
  for use with whisker templates.
}

