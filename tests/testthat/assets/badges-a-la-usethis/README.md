# thisisatest <img src='man/figures/logo.png' align="right" height="138.5" />

> Connect to thisisatest, from R

<!-- badges: start -->
[![Linux Build Status](https://travis-ci.org/thisisatest/thisisatest.svg?branch=master)](https://travis-ci.org/thisisatest/thisisatest)
<!-- badges: end -->

## Introduction

The [thisisatest builder](https://builder.thisisatest.io/) is a multi-platform build and
check service for R packages. The `thisisatest` packages uses the thisisatest API to connect to
the thisisatest builder and start package checks on various architectures:
**Run `R CMD check` on any of the thisisatest builder architectures, from R**.

The `thisisatest` package also supports accessing **statuses of previous checks**, and
**local use of the thisisatest Linux platforms via Docker**.
