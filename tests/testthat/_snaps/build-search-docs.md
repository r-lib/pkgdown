# build_search_index() captures the expected data

    Code
      str(build_search_index(pkg))
    Output
      List of 4
       $ :List of 8
        ..$ path             : chr "https://example.com/authors.html"
        ..$ id               : chr NA
        ..$ dir              : chr ""
        ..$ previous_headings: chr ""
        ..$ what             : chr "Authors"
        ..$ title            : chr "Authors and Citation"
        ..$ text             : chr "Jo Doe. Author, maintainer."
        ..$ code             : chr ""
       $ :List of 8
        ..$ path             : chr "https://example.com/authors.html"
        ..$ id               : chr "citation"
        ..$ dir              : chr ""
        ..$ previous_headings: chr ""
        ..$ what             : chr "Citation"
        ..$ title            : chr "Authors and Citation"
        ..$ text             : chr "Doe J (2024). testpackage: test package. R package version 1.0.0 URL , {{ URL }}."
        ..$ code             : chr "@Manual{,   title = {testpackage: A test package},   author = {Jo Doe},   year = {2024},   note = {R package ve"| __truncated__
       $ :List of 8
        ..$ path             : chr "https://example.com/index.html"
        ..$ id               : chr "my-package"
        ..$ dir              : chr ""
        ..$ previous_headings: chr ""
        ..$ what             : chr "A test package"
        ..$ title            : chr "A test package"
        ..$ text             : chr "pakage "
        ..$ code             : chr ""
       $ :List of 8
        ..$ path             : chr "https://example.com/news/index.html"
        ..$ id               : chr "version-100"
        ..$ dir              : chr "Changelog"
        ..$ previous_headings: chr ""
        ..$ what             : chr "Version 1.0.0"
        ..$ title            : chr "Version 1.0.0"
        ..$ text             : chr "Bullet 1 Bullet 2"
        ..$ code             : chr ""

# build sitemap only messages when it updates

    Code
      build_sitemap(pkg)
    Message
      -- Building sitemap ------------------------------------------------------------
      Writing `sitemap.xml`
    Code
      build_sitemap(pkg)
    Message
      -- Building sitemap ------------------------------------------------------------

