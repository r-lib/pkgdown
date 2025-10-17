# Automatically link references and articles in an HTML page

**deprecated**

`intro`: â€œGet Startedâ€?, which links to a vignette or article with
the same name as the package[¹](#fn1).

``` yaml
template:
  includes:
    before_title: <!-- inserted before the package title in the header ->
    before_navbar: <!-- inserted before the navbar links -->
    after_navbar: <!-- inserted after the navbar links -->
```

These inclusions will appear on all screen sizes, and will not be
collapsed into the the navbar drop down.

You can also customise the colour scheme of the navbar by using the
`type` and `bg` parameters. See above for details.

``` r
usethis::create_package("~/desktop/testpackage")
# ... edit files ...
pkgdown::build_site(tmp, new_process = FALSE, preview = FALSE)
```

Once you have built a minimal package that recreates the error, create a
GitHub repository from the package (e.g. with
[`usethis::use_git()`](https://usethis.r-lib.org/reference/use_git.html) +
[`usethis::use_github()`](https://usethis.r-lib.org/reference/use_github.html)),
and file an issue with a link to the repository.

pkgdown is designed to make it quick and easy to build a website for
your package. You can see pkgdown in action at
<https://pkgdown.r-lib.org>: this is the output of pkgdown applied to
the latest version of pkgdown. Learn more in
[`vignette("pkgdown")`](https:/pkgdown.r-lib.org/articles/pkgdown.md) or
[`?build_site`](https:/pkgdown.r-lib.org/reference/build_site.md).

------------------------------------------------------------------------

1.  Note that dots (`.`) in the package name need to be replaced by
    hyphens (`-`) in the vignette filename to be recognized as the
    intro. That means for a package `foo.bar` the intro needs to be
    named `foo-bar.Rmd`.
