# build_search_index() has expected structure

    Code
      str(build_search_index(pkg))
    Output
      List of 1
       $ :List of 8
        ..$ path             : chr "https://example.com/index.html"
        ..$ id               : chr "my-package"
        ..$ dir              : chr ""
        ..$ previous_headings: chr ""
        ..$ what             : chr "A test package"
        ..$ title            : chr "A test package"
        ..$ text             : chr "pakage "
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

