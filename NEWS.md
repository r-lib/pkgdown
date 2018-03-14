# pkgdown 0.1.0.9000

* Major refactoring of path handling. `build_` functions no longer take
  `path` or `depth` arguments. Instead, set the `destination` directory 
  at the top level of `pkgdown.yml`.
