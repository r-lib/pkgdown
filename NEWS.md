# pkgdown 1.0.0.9000

* Improved display for icons - icons now must be 30px and are embedded in 
  separate column of reference index table (instead of being inside 
  a comment!) (#607).

# pkgdown 1.0.0

* Major refactoring of path handling. `build_` functions no longer take
  `path` or `depth` arguments. Instead, set the `destination` directory 
  at the top level of `pkgdown.yml`.

* Similarly, `build_news()` no longer takes a `one_page` argument;
  this should now be specified in the `_pkgdown.yml` instead. See the 
  documentation for an example.
