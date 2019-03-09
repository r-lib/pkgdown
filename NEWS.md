# pkgdown 1.3.0.9000 (development version)

* A default 404 page (`404.html`) is built from content in `.github/404.md` (#947).

* Updated fontawesome to 5.7.1. [fontawesome 5 deprecated the `fa` prefix style](https://fontawesome.com/how-to-use/on-the-web/referencing-icons/basic-use),
  so fontawesome users need to migrate their icons from `fa fa-home` to `fas fa-home`. Note
  that brands now have a separate prefix (`fab fa-github`) (#953).

* Optionally, opt of out of installation in `deploy_site_github()`

* `\tabular{}` conversion better handles code (@mitchelloharawild, #978).

# pkgdown 1.3.0

* Restore accidentally deleted `build_logo()` function so that logos
  are once more copied to the website.

* Fix to `pkgdown.css` so page header has correct amount of top margin.

* `content-home.html` template is no longer used when the homepage
  is an `.Rmd` (Reverts #834. Fixes #927, #929)

* `deploy_site_github()` now passes parameters to `build_site()` 
  (@noamross, #922), and the documentation gives slightly better advice.

* Correct off-by-one error in navbar highlighting javascript; now no navbar
  is highlighted if none match the current path (#911).

* Tweaking of HTML table classes was fixed (@yonicd, #912)

* Restore accidentally removed `docsearch.css` file.

# pkgdown 1.2.0

## New features

* `deploy_site_github()` can be used from continuous intergration systems
  (like travis) to automatically deploy your package website to GitHub Pages.
  See documentation for how to set up details (@jimhester).

* `build_favicon()` creates high resolution favicons from the package logo,
  and saves them in `pkgdown/`. They are created using the 
  <http://realfavicongenerator.net> API, and are better suited for modern web 
  usage (e.g. retina display screens, desktop shortcuts, etc.). This also 
  removes the dependency on the magick package, making automated deployment
  a little easier (@bisaloo, #883).

* Users with limited internet connectivity can explicitly disable internet
  usage by pkgdown by setting `options(pkgdown.internet = FALSE)` (#774, #877).

## Improvements to Rd translation

* `rd2html()` is now exported to facilitate creation of translation reprexes.

* `\Sexpr{}` conversion supports multiple arguments, eliminating 
  `x must be a string or a R connection` errors when using `\doi{}` (#738).

* `\tabular{}` conversion better handles empty cells (#780).

* `\usage{}` now supports qualified functions eliminating  
  `Error in fun_info(x) : Unknown call: ::` errors (#795).

* Invalid tags now generate more informative errors (@BarkleyBG, #771, #891)

## Front end

* The default footer now displays the version of pkgdown used to build 
  the site (#876). 

* All third party resources are now fetched from a single CDN and are
  give a SRI hash (@bisaloo, #893).
  
* The navbar version now has class "version" so you can more easily control 
  its display (#680).

* The default css has been tweaked to ensure that icons are visible on all
  browsers (#852).

## Bug fixes and minor improvements

### Home page

* Can now build sites for older packages that don't have a `Authors@R` field 
  (#727).

* Remote urls ending in `.md` are no longer tweaked to end in `.html` (#763).

* Bug report link is only shown if there's a "BugReports" field (#855).

* `content-home.html` template is now used when the homepage is an `.Rmd` 
  (@goldingn, #787).

* A link to the source `inst/CITATION` was added to the authors page (#714).

### News

* Uses stricter regular expression when linking to GitHub authors (#902).

### Reference

* Unexported functions and test helpers are no longer loaded (#789).
  
* Selectors that do not match topics now generate a warning. If none of the 
  specified selectors have a match, no topics are selected (#728).

### Articles

* The display depth of vignette tables of contents can be configured by 
  setting `toc: depth` in `_pkgdown.yml` (#821):

  ```yaml
  toc:
    depth: 2
  ```

### Overall site

* `init_site()` now creates a CNAME file if one doesn't already exist and the
  site's metadata includes a `url` field.

* `build_site()` loses vestigal `mathjax` parameter. This didn't appear to do 
  anything and  no one could remember why it existed (#785).

* `build_site()` now uses colors even if `new_process = TRUE` (@jimhester).

# pkgdown 1.1.0

## New features

* `build_reference()` and `build_site()` get new `document` argument. When 
  `TRUE`, the default, will automatically run `devtools::document()` to 
  ensure that your documentation is up to date.

* `build_site()` gains a `new_process` argument, which defaults to `TRUE`.
  This will run pkgdown in a separate process, and is recommended practice
  because it improves reproducibility (#647).

* Improved display for icons: icons must be 30px and stored in top-level 
  `icons/` directory. They are embedded in a separate column of reference 
  index table, instead of being inside a comment (!) (#607).
  
## Front end

* Added a keyboard shortcut for searching. Press `shift` + `/` (`?`) to move 
  focus to the search bar (#642). 
  
* The Algolia logo is correctly shown in the search results (#673).
 
* Navbar active tab highlighting uses a superior approach (suggested by 
  @jcheng5) which should mean that the active page is correctly highlighted
  in all scenarios (#660).

* `pkgdown.js` is better isolated so it should still work even if you 
  load html widgets that import a different version of jquery (#655).

## Improvements to Rd translation

* `vignette()` calls that don't link to existing vignettes silently fail 
  to link instead of generating an uninformative error messages (#652). 
  Automatic linking works for re-exported objects that are not functions 
  (@gaborcsardi, #666).

* Empty `\section{}`s are ignored (#656). Previously, empty sections caused 
  error `Error in rep(TRUE, length(x) - 1)`.

* `\Sexpr{}` supports `results=text`, `results=Rd` and `results=hide` (#651).

* `\tabular{}` no longer requires a terminal `\cr` (#664, #645).

## Minor bug fixes and improvements

* Add `inst/pkgdown.yml` as a possible site configuration file so that packages 
  on CRAN can be built without needing the development version (#662).

* Default navbar template now uses site title, not package name (the package 
  name is the default title, so this will not affect most sites) (#654).

* You can suppress indexing by search engines by setting `noindex: true` 
  `pkgdown.yml` (#686)
  
    ```yaml
    template:
      params:
        noindex: true
    ```

* `build_article()` sets `IN_PKGDOWN` env var so `in_pkgdown()` works 
  (#650).

* `build_home()`: CITATION files with non-UTF-8 encodings (latin1) work
  correctly, instead of generating an error. For non-UTF-8 locales, ensure you 
  have e.g. `Encoding: latin1` in your `DESCRIPTION`; but best practice is to 
  re-enode your CITATION file to UTF-8 (#689).

* `build_home()`: Markdown files (e.g., `CODE_OF_CONDUCT.md`) stored in 
  `.github/` are copied and linked correctly (#682).

* `build_news()`: Multi-page changelogs (generated from `NEWS.md` with
  `news: one_page: false` in `_pkgdown.yml`) are rendered correctly.

* `build_reference()`: reference index shows infix functions (like `%+%`) as 
  `` `%+%` ``, not `` `%+%`() `` on  (#659).

# pkgdown 1.0.0

* Major refactoring of path handling. `build_` functions no longer take
  `path` or `depth` arguments. Instead, set the `destination` directory 
  at the top level of `pkgdown.yml`.

* Similarly, `build_news()` no longer takes a `one_page` argument;
  this should now be specified in the `_pkgdown.yml` instead. See the 
  documentation for an example.
