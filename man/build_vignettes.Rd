\name{build_vignettes}
\alias{build_vignettes}
\title{List all package vignettes.}
\usage{
  build_vignettes(package, base_path)
}
\arguments{
  \item{package}{package to explore}
}
\value{
  a list, with one element for each vignette containing the
  vignette title and file name.
}
\description{
  Copies all vignettes and returns data structure suitable
  for use with whisker templates.
}

