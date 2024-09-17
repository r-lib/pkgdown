# pkgdown 2.1.1

* Added keyboard shortcut, `/`, to focus search bar (#2423)
* The `BugReports` field can now be an email (@catalamarti, #2275).
* New `clean_cache()` function removes the contents of the cache directory (#2718).
* pkgdown now depends on R >= 4.0.0 (#2714)
* Updated GitHub Actions advice and workflows around Quarto install (@tanho63, #2743)

# pkgdown 2.1.0

## Major changes

* Added @olivroy and @salim-b as pkgdown authors in recognition of their contributions.
* `build_articles()` and `build_article()` now support articles/vignettes written with quarto (version 1.5 and above). Combining the disparate quarto and pkgdown templating systems is a delicate art, so while I've done my best to make it work, there may be some rough edges. So please file an issue you encounter quarto features that don't work quite right. Learn more in `vignette("quarto")`(#2210).
* New light switch makes it easy for users to switch between light and dark themes for the website (based on work in bslib by @gadenbuie). For now this behaviour is opt-in with `template.light-switch: true` but in the future we may turn it on automatically. See the customization vignette for details (#1696).
* New `vignette("translations")` that discusses non-English sites including how to submit new translations (#2605).
* New `vignette("accessibility")` describes what manual tasks you need to perform to make your site as accessible as possible (#2344).
* New `template.math-rendering` allows you to control how math is rendered across your site. The default uses `mathml` which is low-dependency, but has the lowest fidelity. You can also use `mathjax`, the previous default, and `katex`, a faster alternative. (#1966).
* All external assets (JS, CSS, fonts) are now directly included in the site instead of fetched from external CDN (@salim-b, #2249)
* YAML validation has been substantially improved so you should get much clearer errors if you have made a mistake (#1927). Please file an issue if you find a case where the error message is not helpful.

## Lifecycle changes

* `autolink_html()` was deprecated in pkgdown 1.6.0 and now warns every time you use it. `downlit::downlit_html_path()` should be used instead.
* `build_site(document)` and `build_reference(document)` has been removed after being deprecated in pkgdown 1.4.0. `devel` should be used instead.
* `preview_page()` has been deprecated (#2650).
* Bootstrap 3 has been deprecated. It was superseded in December 2021, and now we're starting to more directly encourage folks to move away from it.

## Front end changes

* When built on GitHub, source urls now use the name of the current upstream branch (rather than `HEAD`), which is more likely to generate correct links (#2597).
* The search dropdown has been tweaked to look more like the other navbar menu items (#2338).
* Improve HTML5 compliance (#2369):
  * No longer support IE9 or earlier
  * Strip trailing whitespace
  * Label `<nav>`s and improve navbar html.
* Tweaked navbar display on mobile so that long titles in drop downs (e.g. article titles) are now wrapped, and the search input spans the full width (#2512).
* The title for the "Reference" page is now "Package index" since this page might contain more than just function details (#2181).
* Very wide words are now automatically broken across lines and hyphenated (when possible) when they'd otherwise create a horizontal scrollbar on mobile (#1888).
* The mobile version of pkgdown sites no longer has a scrollburglar (a small amount of horizontal scroll) (#2179, @netique).
* Anchors are displayed when they're the target of a link.
* New translation for "Search site", the label applied to the search box for screenreaders. This was previously incorrectly labelled as "Toggle navigation" (#2320).
* pkgdown no longer overrides the default selection colours. This improves accessibility for users who have set their own colours in their browser settings (#2139, @glin).
* If you put a dropdown menu (e.g. articles) on the right hand side of the navbar, it will now be right aligned. This makes longer titles more likely to stay on the page (#2421).
* BS5 templates no longer include empty link to logo when none exists (#2536).
* Updated translations from @jplecavalier, @dieghernan, @krlmlr, @LDalby, @rich-iannone, @jmaspons, and @mine-cetinkaya-rundel (#2659).

## `_pkgdown.yaml`

* Anywhere you can use `_pkgdown.yml`, you can now use `_pkgdown.yaml` (#2244).
* Custom navbars that specify `icon` but not `aria-label` will now generate a message reminding you to provide one for to improve accessibility (#2533).
* The `repo.source.url` field no longer requires a trailing slash (#2017).
* The `template.bslib` item now also accepts a `bootswatch` key (@gadenbuie, #2483).
* You can now choose where the search box is placed with the "search" navbar component. This has been documented for a very long time, but as far as I can tell, never worked (#2320). If you have made your own template with a custom `navbar`, you will need to remove the `<form>` with `role="search"` to avoid getting two search boxes.

## Minor improvements and bug fixes

* pkgdown now uses httr2 instead of httr (#2600).
* Mathjax now uses version 3.2.2.
* The addin now runs `build_site()` instead of `build_site_external()`, which generally should be more reliable (#2252).
* `<source>` tags now have their `srcref` attributes tweaked in the same way that the `src` attributes of `<img>` tags are (#2402).
* `as.pkgdown()` will no longer prompt you to install a missing template package from CRAN, since these are almost always found in GitHub (#2076).
* `build_articles()` now recognises a new `external-articles` top-level field that allows you to define articles that live in other packages (#2028).
* `build_article()` no longer has a `data` argument. This is technically a breaking change, but I can't figure out why anyone would have ever used it.
* `build_*()` (apart from `build_site()`) functions no longer default to previewing in interactive sessions since they now all emit specific links to newly generated files.
* `build_article()` now translates the "Abstract" title if it's used.
* `build_article()` now escapes html characters in the title (#2286).
* `build_article()` no longer generates the wrong source link when you build your site outside of the root directory (#2172).
* `build_articles()` now reports if you are missing alt-text for any images (#2357).
* `build_articles()` now drops a section called "internal". This allows you to have articles that either aren't indexed at all or are included manually elsewhere in the navbar (#2205).
* `build_home()` now correctly escapes special HTML characters in the bibtex citation (#2022).
* `build_home()` no longer checks if the README is missing any images. This check is now performed in `build_site()`, after `build_articles()` so you can refer to images created by vignettes with warnings (#2194).
* `build_home()` now includes the contents of `inst/AUTHORS` on the authors page (#2506).
* `build_home_index()` now reports when rendering the home page (#2544).
* `build_home_index()` now renders math if you use it in your home page (#2263).
* `build_news()` now works if your package has been archived at some point (#2687).
* `build_news()` only syntax highlights the page once, not twice, which prevents every block of R code getting a blank line at the start (#2630).

    ```R
    1 + 1
    ```
* `build_reference()` no longer displays `\dontshow{}` or `\testonly{}` blocks in examples. It will run the code in `\dontshow{}`; it won't run the code in `\testonly{}`(#2188).
* `build_reference()` does a better job of parsing `\value{}` blocks (#2371).
* `build_reference()` now generates the usage that users actually type for infix and replacement methods (#2303).
* `build_reference()` now automatically translates `--`, `---`, ``` `` ```, and `''` to their unicode equivalents (#2530).
* `build_reference()` now supports `\Sexpr[results=verbatim]` (@bastistician, #2510).
* `build_reference()` adds anchors to arguments making it possible to link directly to an argument, if desired. A subtle visual treatment makes it easy to see which argument is targeted (#2228).
* `build_reference()` now automatically renders any tables created by gt (#2326).
* `build_reference()` matches usage for S3 and S4 methods to the style used by R 4.0.0 and later (#2187).
* `build_reference_index()` now displays function lifecycle badges next to the function name (#2123). The badges are extracted only from the function description. You can now also use `has_lifecycle()` to select functions by their lifecycle status.
* `build_redirects()` is now exported to make it easier to document (#2500).
* `build_redirects()` now automatically adds redirects for topic
aliases. This matches the behaviour of `?` and will help keep links stable in the long term (#1876).
* `build_redirects()` now reports which redirects it is generating.
* `build_site()` automatically runs `pkgdown_sitrep()` at the start of the process (#2380).
* `build_sitemap()` no longer includes redirected pages (#2582).
* `check_pkgdown()` and `pkgdown_sitrep()` have been unified so that they both report on the same problems. They now only differ in the style of their output: `pkgdown_sitrep()` reports whether each category is ok or not ok, while `check_pkgdown()` errors on the first issue (#2463).
* `init_site()` will no longer automatically build favicons on CI systems (e.g. GHA). This is an expensive operation that uses an external service so it should only be run locally (#2553).
* `init_site()` once again describes one copy per line, and now uses a better prefix when copying assets from pkgdown itself (#2445).
* `pkgdown_sitrep()`/`check_pkgdown()` now check that you have up-to-date favicons if you have a package logo.
* `template_reference()` and `template_article()` now only add backticks to function names if needed (#2561).
* `vignette("search")` has been removed since BS3 is deprecated and all the BS5 docs are also included in `build_search()` (#2564).

# pkgdown 2.0.9

* Fixes for regressions in 2.0.8:

  * Output links generated when building the site work once again (#2435).

  * pkgdown once again uses Bootstrap version specified in a template
    package (@gadenbuie, #2443).

* Front-end improvements:

  * The skip link now becomes visible when focussed (#2138). Thanks to @glin
    for the styles!

  * The left and right footers no longer contain an extra empty paragraph tag
    and the footer gains additional padding-top to keep the whitespace constant
    (#2381).

  * Clipboard buttons report their action again ("Copied!") (#2462)

* It is now easier to preview parts of the website locally interactively.
  `build_reference_index()` and friends will call `init_site()` automatically
  instead of erroring (@olivroy, #2329).

* `build_article()` gains a new `new_process` argument which allows to build a
   vignette in the current process for debugging purposes. We've also improved
   the error messages and tracebacks if an article fails to build, hopefully
   also making debugging easier (#2438).

* `build_article_index()` and `build_reference_index()` use an improved BS5
  template that correctly wraps each section description in a `<div>`, rather
  than a `<p>`. This eliminates an empty pargraph tag that preceded each section
  description (#2352).

* `build_home()` no longer errors when you have an empty `.md` file (#2309).
  It alos no longer renders Github issue and pull request templates
  (@hsloot, #2362)

* `build_news()` now warns if it doesn't find any version headings, suggesting
  that that `NEWS.md` is structured incorrectly (#2213).

* `build_readme()` now correctly tweaks links to markdown files that use an
  anchor, e.g. `foo.md#heading-name` (#2313).

* `build_reference_index()` gives more informative errors if your `contents`
  field is malformed (#2323).

* `check_pkgdown()` no longer errors if your intro vignette is an article is
  not listed in `_pkgdown.yml` (@olivroy #2150).

* `data_template()` gives a more informative error if you've misspecified the navbar (#2312).

# pkgdown 2.0.8

* pkgdown is now compatible with (and requires) bslib >= 0.5.1
  (@gadenbuie, #2395), including a fix to BS5 navbar template to get
  `navbar.type: dark` to work with Bootstrap 5.3+ (@tanho63, #2388)

* Now uses [cli](https://github.com/r-lib/cli) to provide interactive feedback.

* Avoid unwanted linebreaks from parsing `DESCRIPTION` (@salim-b, #2247).

* Translations
  * New Catalan translation (@jmaspons, #2333).
  * Citation sections are correctly translated (@eliocamp, #2410).

* `build_article_index()` now sorts vignettes and non-vignette articles
   alphabetically by their filename (literally, their `basename()`), by default
   (@jennybc, #2253).

* Deprecated `build_favicon()` was removed (`build_favicons()` remains).

* `build_articles()` now sets RNG seed by default. Use
  `build_articles(seed = NULL)` for the old (unreproducible) behaviour.
  (@salim-b, #2354).

* `build_articles()` will process `.qmd` articles with the quarto vignette
  builder (@rcannood, #2404).

* `build_articles()` and `build_reference()` now set RNG seed for htmlwidgets
  IDs. This reduces noise in final HTML output, both for articles and examples
  that contain htmlwidgets (@salim-b, #2294, #2354).

* `build_news()` correctly parses  of github profiles and issues into links
  when present at the beginning of list items (@pearsonca, #2122)

* `build_reference()` sets `seed` correctly; it was previously reset too early
   (@salim-b, #2355)

* Rd -> html translation
  * `\cr` is now translated to `<br>` not `<br />` (#2400).
  * Correct usage for S3 methods with non-syntactic class names (#2384).
  * Preserve Markdown code blocks with class rmd from roxygen2 docs (@salim-b, #2298).

* `build_reference_index()` no longer generates redundant entries when multiple
  explicit `@usage` tags are provided (@klmr, #2302)

* `build_reference_index()` correctly handles topic names that conflict with
  selector functions (@dmurdoch, #2397).

# pkgdown 2.0.7

* Fix topic match selection when there is an unmatched selection followed by a matched selection (@bundfussr, #2234)
* Fix highlighting of nested not R code blocks (for instance, example of R
Markdown code with chunks) (@idavydov, #2237).
* Tweak German translation (@krlmlr, @mgirlich, @lhdjung, #2149, #2236)
* Remove mention of (defunct) Twitter card validator, provide alternatives (@Bisaloo, #2185)
* Fix `keywords` typo in `check_missing_topics()` message (@swsoyee, #2178).
* Use jsdeliver CDN for bootstrap-toc (@GregorDeCillia, #2207).

# pkgdown 2.0.6

* If you're using an RStudio daily, output file names are now clickable,
  previewing the generated HTML in the browser (#2157).

* Getting started vignette no longer needs to be included in the articles index
  (#2150).

* If there aren't any functions in the `\usage{}` block, then pkgdown will
  now shows all aliases on the reference index, rather than just the topic
  name (#1624).

# pkgdown 2.0.5

* Correctly generate downlit link targets for topics that have a file name
  ending in `.` (#2128).

* `build_articles()`: if build fails because the index doesn't include all
  articles, you're now told what articles are missing (@zkamvar, #2121).

* `build_home()` now escapes angle brackets in author comments(#2127).

* `build_home()` will automatically render and link `.github/SUPPORT.md`
  (@IndrajeetPatil, #2124).

* `build_news()` once again fails to link `@username` at start of
  bullet. I had to reverted #2030 because of #2122.

* `build_reference()`: restore accidentally nerfed `has_keyword()` and
  `has_concept()` reference selectors (#2126) and add tests.

# pkgdown 2.0.4

* New `check_pkgdown()` provides a lightweight way to check that your
  `_pkgdown.yml` is valid without building the site (#2056). Invalid
  `_pkgdown.yml` now consistently generates errors both locally and on
  CI (#2055).

* `build_article()` now supports inline markdown in the `title` (#2039).

* `build_home()` no longer shows development status badges on the released
  version of the site (#2054).

* `build_news()` support automated `@username` links in more places (#2030).

* `build_reference()`:

    * You can once again exclude topics from the reference index with `-` (#2040).

    * Inline markdown in `title`s and `subtitle`s is now supported(#2039).

    * Package logos will be automatically stripped from the `.Rd` you don't end
      up with two on one page. (#2083).

    * `\figure{file}{alternative text}` with multiline alt text is now parsed
      correctly (#2080)

    * roxygen 7.2.0 output for generic code blocks (#2092, @jabenninghoff) is
      processed correctly.

* Front end changes:

    * Automatically added links in code blocks are now styled less aggressively,
      so they occupy less visual weight on the page (#2007).

    * All article pages are given class `col-md-9` for consistency with other
      pages (#2045).

    * Fixed width HTML widgets are sized correctly (@dmurdoch, #2062).

    * Footnotes work with more contents, including code (@banfai, #2042).

    * Navbar components now accept `target` argument (#2089, @JSchoenbachler).

* New syntax highlighting themes a11y-light, a11y-dark, monochrome-light,
  monochrome-dark, and solarized

# pkgdown 2.0.3

* Fixes for R CMD check

# pkgdown 2.0.2

* New Korean (`ko`) translation thanks to @mrchypark and @peremen (#1944).
  New Danish (`dk`) translation thanks to @LDalby.

* `build_articles()` now adjusts the heading levels of vignettes/articles that
  use `<h1>` as section headings to ensure that there's one top-level heading
  (#2004). This ensures that there's one `<h1>`, the title, on each page,
  and makes the TOC in the sidebar work correctly.

* `build_home_index()` no longer spuriously complains about missing images
  if you use plots in your `README.Rmd` (#1980, #1977). It no longer
  tweaks the `src` path for `<img>` tags with absolute paths (#1955).

* `build_news()` once again works if `NEWS.md` uses `<h1>` headings (#1947).

* `build_reference()` now correctly interprets `title: internal`: it removes
  the section from the reference index _and_ it doesn't list the topics in that
  section as missing (#1958).

* `build_reference()` now gives a correct hint when the reference index YAML
  is not formatted correctly (e.g. empty item, or item such as "n" that needs
  to be escaped with quotes to not be interpreted as Boolean) (#1995).

* `deploy_to_branch()` gains a `subdir` argument, allowing you to deploy the
  site to a subdirectory (@gadenbuie, #2001).

* Front end changes:

    * The navbar gets a little more space after the version number, and aligns
      the baseline with rest of the navbar (#1989).

    * Long lines in code output once again scroll, rather than being wrapped.
      While this is different to what you'll see in the console, it's a better
      fit for web pages where the available code width varies based on the
      browser width (#1940).

    * scrollspy (which highlights the "active" heading in the sidebar) now
      computes the offset dynamically which makes it work better on sites with
      taller navbars (#1993).

    * Fixed js issues that occurred on pages without a table of contents
      (@gadenbuie, #1998).

    * When htmlwidgets with jQuery or Bootstrap dependencies are used in examples or
      articles, pkgdown's versions of jQuery and Boostrap will take precedence over
      the versions used by the htmlwidget (@gadenbuie, #1997).

* pkgdown no longer includes bundled author metadata for Hadley Wickham,
  RStudio, or the RConsortium, since there are now ways to include this
  meta data in template packages, and special casing these three entities
  feels increasingly weird (#1952).

# pkgdown 2.0.1

* Fix CRAN failures.

* Reference sections are de-duplicated correctly (#1935).

* Usage sections only generated for topics that have them; usage correctly
  displayed with BS3 (#1931)

* Empty `\value{}` no longer errors (#1930).

# pkgdown 2.0.0

## New authors

@maelle is now a pkgdown author in recognition of her significant and sustained contributions. She was the powerhouse behind many of the improvements in this release, particularly the switch to bootstrap 5, improvements to customisation, and implementation of local search.

## Bootstrap 5

* pkgdown can style your site with Bootstrap 5 (with help from @jayhesselberth,
  @apreshill, @cpsievert). Opt-in by setting `boostrap` version in your
  `_pkgdown.yml`:

    ```yaml
    template:
      bootstrap: 5
    ```

* We reviewed site accessibility and made a number of small improvements:
  (#782, #1553):

    * Default font is larger and links are always underlined.
    * Heading anchors use `aria-hidden` to reduce noise for screenreader users.
    * Navbar dropdowns has improved `aria-labelledby`.
    * The default GitHub/GitLab links gain an `aria-label`; use for other
      icons is now supported, and encouraged in the docs.
    * Syntax highlighting uses a new more
      [accessible colour scheme](https://apreshill.github.io/rmda11y/arrow.html),
      designed by Alison Hill (#1536)
    * A skip link makes it easier to get directly to the page contents (#1827).

* In-line footnotes mean you can read asides next to the text they refer to.

* Articles support tabsets,
  [as in R Markdown](https://bookdown.org/yihui/rmarkdown-cookbook/html-tabs.html).
  (@JamesHWade, #1667).

* Other minor styling improvements:

    * The active item in TOC is indicated with background colour, rather than
      a border.
    * If present, the package logo is shown on all pages near the header.
    * Section anchors now appear on the right (making them usable on mobile
      phones) (#1782).
    * The TOC is scrollable independently of the main content. This makes it
      more useful on long pages with many headings (#1610).
    * The sidebar is shown at the bottom of the page on narrow screens.
    * Function arguments and the reference index (#1822) use definition lists
      (`<dl>`) instead of tables. This gives more room for long argument
      names/lists of function and detailed descriptions, and displays better
      on mobile.
    * Links on the homepage no longer show the full url in the text.
    * The default navbar no longer includes a home icon - this took up
      precious horizontal space and wasn't very useful since there was already
      a link to the home page immediately to its left (#1383).

## Local search

* pkgdown now supports local searching (i.e. searching without an external
  service), and is enabled by default for Bootstrap 5 sites since no set-up is
  needed (#1629, with help from @gustavdelius in #1655 and @dieghernan &
  @GregorDeCillia in #1770).

* pkgdown builds a more exhaustive `sitemap.xml` even for websites built with
  Bootstrap 3. This might change Algolia results if you use Algolia for search
  (#1629).

## Customisation

* New `vignette("customise")` documents all the ways you can customise your
  site, including the new options described below (#1573).

* Sites can be easily themed with either bootswatch themes or by selectively
  overriding the `bslib` variables used to generate the CSS. pkgdown now uses
  scss for its own Bootstrap css tweaks, which means that you can customise
  more of the site from within `_pkgdown.yml`.

* You can pick from a variety of built-in syntax highlighting themes (#1823).
  These control the colours (and background) of code in `<pre>` tags.

* pkgdown can now translate all the text that it generates (#1446): this means
  that if you have a package where the docs are written in another language, you
  can match all the pkgdown UI to provide a seamless experience to non-English
  speakers. Activate the translations by setting the `lang` in `_pkgdown.yml`:

    ```yaml
    lang: fr
    ```

    pkgdown includes translations for:

    * `es`, Spanish, thanks to @edgararuiz-zz, @dieghernan, @rivaquiroga.
    * `de`, German, thanks to @hfrick.
    * `fr`, French, thanks to @romainfrancois, @lionel-, @jplecavalier, and @maelle.
    * `pt`, Portuguese, thanks to @rich-iannone.
    * `tr`, Turkish, thanks to @mine-cetinkaya-rundel.
    * `zh_CN`, simplified Chinese, thanks to @yitao.

    If you're interested in adding translations for your language please file
    an issue and we'll help you get started.

* Template packages can now provide `inst/pkgdown/_pkgdown.yml` which is used
  as a set of defaults for `_pkgdown.yml`. It can be used to (e.g.) provide
  author definitions, select Bootstrap version and define bslib variables,
  and customise the sidebar, footer, navbar, etc. (#1499).

* New `includes` parameters `in-header`, `before-body`, and `after-body`
  make it easy to add arbitrary HTML to every page. Their content will be
  placed at the end of the `<head>` tag, right below the opening `<body>` tag,
  and before the closing tag `</body>` respectively (#1487). They match the
  bookdown options `in_header`, `before_body` and `after_body`.

    Additionally, you can use `before_title`, `before_navbar`, and
    `after_navbar` to add arbitrary HTML into the navbar/page header; they
    will appear to the left of the package name/version, and to the left and
    right of the navigation links respectively (#1882).

* Authors configuration is more flexible (#1516). You can now:

    * Choose the roles used for filtering authors for the sidebar and footer.
    * Choose the text before authors in the footer.
    * Add text before and after the authors list in the sidebar.
    * Add text before and after the authors list of the authors page.

* Sidebar specification is more flexible (#1443, #1488, #1502). You can now:

    * Change the order of sidebar elements.
    * Add custom sidebar sections (with Markdown/HTML `text`).
    * Add a table of contents to the home page.
    * Completely suppress the sidebar.
    * Provide your own HTML for the navbar.

* Footer specification is more flexible (#1502). You can now:

    * Change the placement of elements on the left and right.
    * Add text to the left and right (or even remove/replace default text)

* You can now exclude all default components from the navbar (#1517).

* Expert users can now override layout templates provided by pkgdown or template
  packages by placing template files in `pkgdown/templates` (@gadenbuie, #1897).

## New features

* pkgdown now supports redirects (#1259, @lorenzwalthert). The following yaml
  demonstrates the syntax, with old paths on the left and new paths/URLs on
  the right.

  ```yaml
  redirects:
    - ["articles/old-vignette-name.html", "articles/new-vignette-name.html"]
    - ["articles/another-old-vignette-name.html", "articles/new-vignette-name.html"]
    - ["articles/yet-another-old-vignette-name.html", "https://pkgdown.r-lib.org/dev"]
  ```

* Use HTML classes `pkgdown-devel` or `pkgdown-release` to declare that certain
  content should appear only on the devel or release site. Use the class
  `pkgdown-hide` for content that should only appear only on GitHub/CRAN
  (#1299).

* New `pkgdown_sitrep()` function reports whether the site is set up correctly;
  in particularly it currently reports if auto-linking will work (#1478).

## Code

* Styling for errors, warnings, and messages has been tweaked. Messages
  are now displayed the same way as output, and warnings and errors are
  bolded, not coloured. This is part of a suite of changes that aim to
  give package authors greater control over the appearance of messages,
  warnings, and errors.

* Long lines in code output are now wrapped, rather than requiring scrolling.
  This better matches `rmarkdown::html_document()` and what you see in the
  console.

* `build_reference()` now allows linking to topics from other packages (either
  function names e.g. `rlang::is_installed` or topic names e.g.
  `sass::font_face`). (#1664)

* `build_reference()` now runs examples with
  `options(rlang_interactive = FALSE)` (ensuring non-interactive behaviour in
  functions that use `rlang::is_interactive()`), `options(cli.dynamic = FALSE)`,
  `Sys.setenv(RSTUDIO = NA)` and `Sys.setLocale("LC_COLLATE", "C")` (#1693).
  It also runs `pkgdown/pre-reference.R` before and `pkgdown/post-reference.R`
  after examples. These allow you to do any setup or teardown operations you
  might need (#1602).

* A reference index section with `title: internal` is now silently dropped,
  allowing you to suppress warnings about topics that are not listed in the
  index (#1716).

* Code blocks are now highlighted according to their declared language
  (e.g. `yaml`) if the documentation was built with roxygen2 7.1.2 or later
  (#1690, #1692).

* New `pkgdown_print()` allows you to control how your objects are rendered in
  examples. It includes built-in handling for htmlwidgets and "browseable" HTML
  so pkgdown output now more closely resembles what you see in RStudio.
  Added extension points to make HTML widgets (and RGL in particular) work
  in rendered examples (@dmurdoch).

* You can globally set the `width` of code output (in reference and articles)
  with

    ```yaml
    code:
      width: 50
    ```

* Articles now render output styles created by cli/crayon (#1556).

* When copy and pasting code blocks, lines containing output (e.g. `#>`)
  are automatically omitted (#1675).

* Auto-linking improvements:

  * Links to inherited R6 methods now work correctly for both internal
    (#1173, @vandenman) and external (#1476) parent classes.

  * Linking no longer fails if a package contains duplicated Rd aliases.

  * Correctly link to reference pages when the `\name{}` entry doesn't match
    the file name (@dmurdoch, #1586; #1676).

## Articles

* Article subtitle, author and date (specified in the YAML frontmatter) are now
  correctly omitted from the article table of contents in the sidebar
  (@maxheld83, #1428).

* Support for `as_is: true` and non-default output formats for vignettes/
  articles has been somewhat improved. Support is fundamentally limited due to
  the challenges of integrating HTML from output formats that pkgdown doesn't
  know about, but it should be a little more reliable and a little better
  documented (#1757, #1764).

* `build_articles()` no longer fails if you have a directory underneath
  vignettes with a `.Rmd` extension (#1425).

* `build_articles()` now correctly handles links to images in `man/figures`
  (which have the form `../man/figures`) (#1472).

* `build_articles()` again sets the `theme` argument of the document format
  to `NULL` when `as_is: true` but lets users override this via the `theme`
  argument of the output format.

* `build_articles()` and `build_home()` now warn if you have images that
  won't render on the website because they're in unsupported directories
  (#1810). Generally, it's only safe to refer to figures in `man/figures`
  and `vignettes`.

* Articles stored in `vignettes/articles` are moved up one level so that they
  appear in `articles/` on the website. Previously, they would appear in
  `articles/articles`, so `build_redirects()` automatically adds redirects for
  any articles in the `vignettes/articles` directory (@gadenbuie #1911).

## HTML, CSS and JS

* New `template` option `trailing_slash_redirect` that allows adding a script to
  redirect `your-package-url.com` to `your-package-url.com/` (#1439, @cderv,
  @apreshill).

* External links now get the class `external-link`. This makes them easier to
  style with CSS (#881, #1491).

* Duplicated section ids are now de-duplicated; this makes pkgdown work better
  with the documentation of R6 classes.

* Updated CSS styles from pandoc to improve styling of reference lists (#1469).

## Deployment

* `build_site_github_pages()` has been extracted out of `deploy_site_github()`
  to make it easier to decouple building and deployment, and so we can take
  advantage of standard deployment actions (#1756).

* `deploy_to_branch()` now calls `git remote set-branches` with `--add` to avoid
  overwriting the existing `remote.{remote}.fetch` value (@kyleam, #1382).
  It also now cleans out the website directory by default; revert to previous
  behaviour with `clean = FALSE` (#1394).

* `build_reference()` will error if envar `CI` is `true` and there are missing
  topics (@ThierryO, #1378).

* You can override the `auto` development mode detected from the package
  version by setting env var `PKGDOWN_DEV_MODE` to `release` or `devel`.
  This is useful if your package uses a different convention to indicate
  development and release versions (#1081).

## Other minor improvements and bug fixes

* `\special{}` tags with complex contents are rendered correctly (@klmr, #1744).

* `\arguments{}` and `\value{}` do a better job of handling mingled items and
  text (#1479). The contents of `\value{}` are now shown immediately after
  `\arguments{}`.

* The default "branch" for linking to the file sources is `HEAD`, which will
  work regardless of whether your default branch is called "main" or "master".

* Non-ORCID comments in `Authors@R` are now more usable: if such comments
  exist, the sidebar gains a link to the authors page, where they are displayed
  (#1516).

* Citations with and without text versions are better handled, and text
  citations are correctly escaped for HTML (@bastistician, #1507).

* README badges in a single paragraph placed between `<!-- badges: end -->`and
  `<!-- badges: end -->` comments are again detected (#1603).

* The 404 page (default or from `.github/404.md`) is no longer built in the
  development mode (see `?build_site`) as e.g. GitHub pages only uses the
  `404.html` in the site root (#1622).

* All links on the 404 pages (navbar, scripts, CSS) are now absolute if there
  is an URL in the configuration file (#1622).

* The version tooltip showed in the top navbar is now only set if you've
  explicitly set the `development.mode` in `_pkgdown.yml` (#1768).

* All heading (e.g. headings on the reference index page, and the arguments
  heading on the reference pages) now get anchors (#1747).

* Use `autolink_bare_uris` for Pandoc above version 2.0 (@marcosmolla, #1618).

* pkgdown now recognizes GitLab URLs to the source repository and adds the
  corresponding icon to the navbar (#1493). It also supports
  [GitLab subgroups](https://docs.gitlab.com/ee/user/group/subgroups/)
  (@salim-b, #1532).

* Links for GitHub Enterprise and GitLab Enterprise repositories are detected
  by assuming such host address begin with `github.` or `gitlab.`
  (@ijlyttle, #1452).

* The rules drawn by the CLI (as for example, in `build_site()`) are protected
  against very narrow terminal windows (@maxheld83, #1435).

* Google Site Verification (https://support.google.com/webmasters/answer/9008080?hl=en)
  can now be configured for pkgdown sites.

* `build_rmarkdown_format` sets `html_document(anchor_sections = FALSE)`
   to avoid needless dependencies (@atusy, #1426).

* Jira issues in NEWS can be automatically linked by setting your project name
  (s) with  `repo: jira_projects: [...]` and specifying a custom issue URL with
  `repo: url: issue: ...` in `_pkgdown.yml` (@jonkeane, #1466).

* `build_home()` always creates citation information for the authors page,
  using metadata from `DESCRIPTION` when there is no `inst/CITATION` file,
  and links to this from the sidebar (#1904).

* `build_news()` no longer breaks with URLs containing numeric fragments
  (@krassowski, #1456), recognises more styles of release heading (#1437),
  and generate stable IDs using a the combination of the heading slug and
  package number. (@Bisaloo, #1015)

# pkgdown 1.6.1

* The article index (used for autolinking vignettes across packages)
  once again works (#1401).

# pkgdown 1.6.0

## Major changes

* pkgdown now uses the new [downlit](https://downlit.r-lib.org/) package for all
  syntax highlighting and autolinking (in both reference topics and vignettes).
  There should be very little change in behaviour because the code in downlit
  was extracted from pkgdown, but this makes it easier to use pkgdown's nice
  linking/highlighting in more places (#1234).

* pkgdown now uses the `ragg::agg_png()` device to generate example figures.
  This should be a little faster and produce higher quality output. Learn
  more at <https://ragg.r-lib.org> (#1320).

## Minor improvements and bug fixes

### Rd translation

* `\special{}` support inside `\usage{}` added to allow non-standard R usage
  syntax (@klmr, #1345).

* `#ifdef` and `#ifndef` are now supported; the "current" OS is hard coded to
  "unix" to ensure reproducible output regardless of where you build the
  website (#1384).

* Nested `\subsection{}`s now generate appropriate heading levels
  (h3, h4, h5 etc) (#1377), and get anchor links (#1389).

* `\preformatted{}` no longer double escapes its contents (#1311).

### Articles and vignettes

* `build_articles()` no longer sets the `theme` argument of the document format
  to `NULL` when `as_is: true`. This should allow it to work with a wider
  range of output formats including `bookdown::html_vignette2()` and
  friends (@GegznaV, #955, #1352).

* When `build_article()` fails, it gives the complete failure message (#1379).

* Markdown header attributes are now processed in all markdown files (@jonkeane, #1343)

### Auto-linking and syntax highlighting

* The branch used for source linking can be configured by setting
  `repo: branch: branch_name` in `_pkgdown.yml` (@jonkeane, #1355):

    ```yaml
    repo:
      branch: main
    ```

* `autolink_html()` is (soft) deprecated. Please use
  `downlit::downlit_html_path()` instead.

* Highlighting of empty expressions works once more (#1310).

* New `deploy$install_metadata` option in `_pkgdown.yml`. Setting it to
  `true` will store site metadata in the package itself, allowing offline
  access for packages that to autolink to the package's website
  (@mstr3336, #1336).

### Other

* You can now control the background colour of plots with the `figures.bg`
  option (it is transparent by default, and given a white background by
  css). See `?build_reference` for an example.

* HTML is automatically stripped from the page title (#1318).

* Suppressing CRAN dates in news file now actually works.

* All HTTP requests are now retried upon failure (@jameslamb, #1305).

* Setting `clean = TRUE` in `deploy_site_github()` removes old files from the
  deployed site before building a new one (#1297).

# pkgdown 1.5.1

* Syntax highlighting works on Windows once more (#1282).

* pkgdown no longer fails if your `.Rd` files have duplicated `\aliases`
  as were produced by an older version of roxygen2 (#1290).

* Rendering empty `.md` file now returns empty string (#1285).

* `build_articles_index()` is now exported to rapidly rebuild the index (#1281)

* `deploy_site_github()` now accepts a `host` argument to specify alternate
  hosts (e.g., Github enterprise) (@dimagor, #1165) and once again works as
  intended on Travis-CI (@jimhester, #1276).

# pkgdown 1.5.0

## New features

* The articles index page and navbar have been overhauled. There are two
  major new features in this release:

    * The articles index page now displays article `description`s,
      taken from YAML metadata belonging to each article. This lets you provide
      more context about each article and describe why one might want to read
      it (#1227).

    * The articles navbar is now also controlled by the `articles` section
      in `_pkgdown.yml`. The ordering of the sections, and articles within
      them, control the order of the articles in the navbar, and you can
      use the new `navbar` field to control whether or not each section
      appears in the navbar (#1101, #1146).

* The reference index now has two levels of heading hierarchy: `title` and
  `subtitle` (#327).

* Tables of contents in sidebars now use
  [bootstrap-toc](https://afeld.github.io/bootstrap-toc/); this considerably
  improves navigation for long articles and reference pages.

* You can now control the links to source files (in reference pages and
  articles) and issues and users (in the NEWS) with new `repo$url` config
  option (#1238). This makes it easier to use pkgdown with GitHub enterprise,
  packages in subdirectories, and other source hosts (like bitbucket).

    ```yaml
    repo:
      url:
        home: https://github.com/r-lib/pkgdown/
        source: https://github.com/r-lib/pkgdown/blob/main/
        issue: https://github.com/r-lib/pkgdown/issues/
        user: https://github.com/
    ```

    The individual components (e.g. path, issue number, username) are pasted on
    the end of these urls so they should have trailing `/`s.

    You don't need to set these links for GitLab, as pkgdown now detects
    GitLab urls automatically (since they use the same structure as GitHub)
    (#1045).

* There's much richer control over Open Graph and Twitter metadata for the
  whole site and for individual articles. See new `vignette("metadata")` for
  details (@gadenbuie, #936).

* New `deploy_to_branch()` function to build and deploy a site to a branch,
  defaulting to `gh-pages` for use with GitHub Pages. This is used in our
  recommended GitHub action workflow for automatically building and deploying
  pkgdown sites for packages on GitHub (@jimhester, #1221).

* Updated JS libraries: jquery 3.3.1 -> 3.4.1; bootswatch 3.3.7 -> 3.4.0;
  bootstrap 3.3.7 -> bootstrap 3.4.1; docsearch 2.6.1 -> 2.6.3;
  fontawesome 5.11.1 -> 5.12.1; headroom.js 0.9.44 -> 0.11.0;
  clipboard.js 2.0.4 -> 2.0.6 (@jayhesselberth).

## Auto-linking improvements

* Examples and Rmd now use exactly the same syntax highlighting strategy.

* In examples and Rmd, calls of the form `current_package::foo` now get
  a local link (#1262).

* `\preformatted{}` blocks are now highlighted and linked if they parse
  as R code (#1180).

* `library(pkgdown)` is now automatically linked to the reference index for
  "pkgdown" not the documentation for `library()` (#1161).

* `help("topic")` is now automatically linked to the documentation for "topic",
  not to the documentation for `help()` (#1210)

## Minor improvements and bug fixes

### Articles

* `build_home()` no longer uses (unrendered) `README.Rmd` or `index.Rmd` if
  corresponding `.md` files are not found.

* `build_article()` failures now print more information to help you debug
  the problem (#952).

* The name of the vignette mapped to the "Get started" entry in the navbar
  is now more flexible. You can use an article (e.g `articles/{pkgname}`)
  and if your package has a `.` in its name you can replace it with `-` to
  generate a valid article name (e.g. the get started vignette for
  `pack.down` would be `pack-down`) (#1166).

### Deployment

* `deploy_to_branch()` now correctly captures the commit SHA on GitHub Actions
  (@coatless, #1252).

* `deploy_to_branch(github_pages = TRUE)` generates a `.nojekyll` to prevent
  jekyll ever executing (#1242).

* `CNAME` is no longer generated by `init_site()`, but is instead conditionally
  by `deploy_to_branch()` when `github_pages = TRUE`. This is a better a fit
  because the `CNAME` file is only needed by GitHub pages (#969).

* `deploy_site_github()` argument `repo_slug` has been deprecated and is no
  longer needed or used. (@jimhester, #1221)

### News
See additional details in `?build_news`:

* You can optionally suppress the CRAN release dates added to the news
  page (#1118).

* Multi-page news style gets a better yaml specification (the old style
  will continue to work so no need to change existing YAML).

### Reference

* A topic named `index` will not longer clobber the reference index (#1110).

* Topic names/aliases on reference index are now escaped (#1216).

* `build_reference()` gives better warnings if your `_pkgdown.yml` is
  constructed incorrectly (#1025).

* New `has_keyword()` topic selector for `reference`. `has_keyword("datasets")`
  is particularly useful for selecting all data documentation (#760).

* New `lacks_concepts()` can select topics that do not contain any of
  a number of specified concepts. (@mikldk, #1232)

### Home, authors, and citation

* pkgdown now escapes html and linkifies links in comments in author info
  from DESCRIPTION (@maelle, #1204)

* pkgdown now uses the ORCiD logo included in Font Awesome 5.11 instead of
  querying it from members.orcid.org (@bisaloo, #1153)

* badges are now extracted from everything between `<!--badges: start-->`
  and `<!--badges: end-->`. They used to be extracted only if they were
  direct children of the first `<p>` after `<!--badges: start-->`.

* `build_home()` now looks for `pkgdown/index.md` in addition to the top-level
  `index` or `README` files (@nteetor, #1031)

### Navbar

* pkgdown now formats the package version displayed in the navbar the same way
  as it has been specified in the DESCRIPTION file. In particular, version
  separators (e.g. `.` and `-`) are preserved. (#1170, @kevinushey)

* add support for navbar submenus: you can create submenus following the
  convention established in [rstudio/rmarkdown#721](https://github.com/rstudio/rmarkdown/issues/721) (@ijlyttle, @wendtke, #1213)

### Other

* Updated JS libraries: jquery 3.3.1 -> 3.4.1; bootswatch 3.3.7 -> 3.4.0;
  bootstrap 3.3.7 -> bootstrap 3.4.1; docsearch 2.6.1 -> 2.6.3
  (@jayhesselberth).

* Markdown conversion now explicitly allows markdown inside of HTML blocks;
  this was previously accidentally disabled (#1220).

* A timestamp for the last site build is reported in `pkgdown.yml` (#1122).

# pkgdown 1.4.1

* Don't install test package in user library (fixes CRAN failure).

# pkgdown 1.4.0

## New features

* build citation as specified by the `textVersion` argument of `citEntry` in the
  `CITATION` file (#1096, @yiluheihei)

* `build_site()`, `build_reference()` and `build_home()` gain a parameter
  `devel` which controls whether you're in deployment or development mode.
  It generalises and replaces (with deprecation) the existing `document`
  argument.

    Development mode is optimised for rapid iteration and is the default
    for `build_reference()`. It uses `pkgload::load_all()` to load code
    directly from disk in order.

    Deployment mode is slower, but guarantees correct results, and is the
    default for `build_site()`. It installs the package into a temporary
    library, and runs examples/articles in a new process.

* `build_reference()` no longer runs `devtools::document()` (#1079) and
  `build_home()` no longer re-builds `README.Rmd` or `index.Rmd`. This makes
  the scope of responsibility of pkgdown more clear: it now only
  creates/modifies files in `doc/`.

* `build_home()` now strips quotes from `Title` and `Description` fields
  when generating page metadata. Additionally, you can now override the
  defaults via the `title` and `description` fields in the `home` section of
  `_pkgdown.yml` (#957, @maelle).

* `vignette("linking")` describes how pkgdown's automatic linking works, and
  how to ensure that cross-package links point to the right place.

## Bug fixes and minor improvements

### Rd translation

* `\examples{}` rendering has been completely overhauled so it now first
  converts the entire mixed Rd-R block to R prior, and then evaluates the
  whole thing. This considerably improves the fidelity of the translation
  at a small cost of no longer being able to remove `\donttest{}` and
  friends (#1087).

* `\item{}`s in `\describe{}` containing whitespace are translated correctly
  (#1117).

* `\dots` and `\ldots` are translated to `...` instead of the ellipsis,
  since they're often found in code (#1114).

* `\tabular{}` translation handles code better (@mitchelloharawild, #978).

* `\subsection{}` contents are now treated as paragraphs, not inline text
  (#991).

* `\preformatted{}` blocks preserve important whitespace (#951).

### Front end

* Links to online documentation for functions in code chunks are no longer
  displayed when printing (#1135, @bisaloo).

* Updated fontawesome to v5.7.1. fontawesome 5 [deprecated the `fa` prefix](https://fontawesome.com/how-to-use/on-the-web/setup/upgrading-from-version-4#changes).
  If you have used custom icons in your navbar, you'll should update them from
  (e.g.) `fa fa-home` to `fas fa-home`. Brands now have a separate prefix so
  `fa fa-github` becomes `fab fa-github` (#953).

* The navbar is now automatically hidden with
  [headroom.js](https://wicky.nillia.ms/headroom.js/).

* The sticky behaviour of the navbar is now implemented in pure CSS instead of
  relying a the 3rd party javascript library (#1016, @bisaloo)

* Favicons are now automatically built from a package logo (#949).

### Linking

* Infix operators (e.g., `%in%` and `%*%`) are now linked to their
  documentation (#1082).

* Function names can now be included in headers without spurious auto-linking
  (#948).

* Links to external documentation now point to [rdrr.io](https://rdrr.io)
  (#998).

### Other

* News page recognises more version specifications (including the
  "(development version)" now used by usethis) (#980).

* Subdirectories are supported for assets (#939, @ijlyttle).

* A default 404 page (`404.html`) is built, unless a custom `.github/404.md`
  is provided (#947).

* `build_article()` now uses the raw vignette title as page `<title>`
  and `og:title` (@maelle, #1037).

* `build_home()` now looks for license files spelled either as LICENSE or
  LICENCE (#972).

* `build_home()` can find badges in paragraph coming after the comment
  `<!-- badges: start -->` (#670, @gaborcsardi, @maelle).

* `build_home()` will add a community section to the sidebar if there is either
  a code of  conduct (`.github/CODE_OF_CONDUCT.md`) or a contributing guide
  (`.github/CONTRIBUTING.md`) (#1044, @maelle).

* `build_reference()` gains a `topics` argument which allows you to re-build
  only specified topics.

* `build_site(new_process = TRUE)` gains a timeout,
  `options(pkgdown.timeout = 10)`, that can be used to prevent stalled
  builds.

* `deploy_site_github(install = FALSE)` makes it possible to opt out of
  installation.

* `dev_mode()` now recognises `0.1.9000` as a development version of a package
  (this is an emerging standard we use for packages with backward incompatible
  changes) (#1101).

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

* `deploy_site_github()` can be used from continuous integration systems
  (like travis) to automatically deploy your package website to GitHub Pages.
  See documentation for how to set up details (@jimhester).

* `build_favicon()` creates high resolution favicons from the package logo,
  and saves them in `pkgdown/`. They are created using the
  <https://realfavicongenerator.net/> API, and are better suited for modern web
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

* `build_site()` now uses colours even if `new_process = TRUE` (@jimhester).

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
