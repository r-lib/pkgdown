staticdocs dummy 3.1
============
* Add "Find me on GitHub" ribbon to allow jumping to the GitHub repository, given in the
  `URLNote` entry in `DESCRIPTION` (#116, @krlmlr).

* Full support for `\linkS4class{}` (#105, @krlmlr).

staticdocs dummy 2.5.9000
============
* Support for strings (in addition to `person()` calls) in `Authors@R` (#106, @krlmlr).

* If no directory `staticdocs` or `inst/staticdocs` exists, and neither `sd_path` and `site_path` are set,
  the the directory `inst/staticdocs` is created, and documentation is created there (#108, @krlmlr).

* Support for subsections added (#112, @krlmlr).

staticdocs dummy 1
============
* External documentation is now forwarded to http://www.rdocumentation.org (#113, @krlmlr).

* Fix rendering of links of the form `\link[pkg]{topic}` where `pkg` is the current package (#115, @krlmlr).
