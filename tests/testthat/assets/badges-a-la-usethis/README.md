# thisisatest <img src='man/figures/logo.png' align="right" height="138.5" />

> Connect to thisisatest, from R

<!-- badges: start -->
[![Linux Build Status](https://travis-ci.org/thisisatest/thisisatest.svg?branch=master)](https://travis-ci.org/thisisatest/thisisatest)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/thisisatest/thisisatest?svg=true)](https://ci.appveyor.com/project/thisisatest/thisisatest)
[![](http://www.r-pkg.org/badges/version/thisisatest)](http://www.r-pkg.org/pkg/thisisatest)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/thisisatest)](http://www.r-pkg.org/pkg/thisisatest)
[![Coverage Status](https://img.shields.io/codecov/c/github/thisisatest/thisisatest/master.svg)](https://codecov.io/github/thisisatest/thisisatest?branch=master)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/thisisatest/community)
<!-- badges: end -->

## Introduction

The [thisisatest builder](https://builder.thisisatest.io/) is a multi-platform build and
check service for R packages. The `thisisatest` packages uses the thisisatest API to connect to
the thisisatest builder and start package checks on various architectures:
**Run `R CMD check` on any of the thisisatest builder architectures, from R**.

The `thisisatest` package also supports accessing **statuses of previous checks**, and
**local use of the thisisatest Linux platforms via Docker**.
