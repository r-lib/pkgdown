# capture data_template()

    package:
      name: testpackage
      version: 1.0.0
    site:
      root: ''
      title: testpackage
    year: <year>
    lang: en
    translate:
      skip: Skip to contents
      toggle_nav: Toggle navigation
      on_this_page: On this page
      source: Source
      abstract: Abstract
      authors: Authors
      version: Version
      examples: Examples
      citation: Citation
      author_details: Additional details
      toc: Table of contents
      site_nav: Site navigation
    has_favicons: no
    opengraph: []
    extra:
      css: ~
      js: ~
    yaml:
      .present: yes
    headdeps: ''
    development:
      destination: dev
      mode: default
      version_label: muted
      in_dev: no
      prefix: ''
      version_tooltip: ''
    navbar:
      bg: light
      type: light
      left: <li class="nav-item"><a class="nav-link" href="reference/index.html">Reference</a></li>
      right: "<li class=\"nav-item\"><form class=\"form-inline\" role=\"search\">\n <input
        class=\"form-control\" type=\"search\" name=\"search-input\" id=\"search-input\"
        autocomplete=\"off\" aria-label=\"Search site\" placeholder=\"Search for\" data-search-index=\"search.json\">
        \n</form></li>"
    footer:
      left: <p>Developed by Jo Doe.</p>
      right: <p>Site built with <a href="https://pkgdown.r-lib.org/">pkgdown</a> {version}.</p>
    lightswitch: no
    uses_katex: no
    uses_mathjax: no
    

# check_opengraph validates inputs

    Code
      data_open_graph_(list(foo = list()))
    Condition
      Warning in `data_open_graph_()`:
      In _pkgdown.yml, template.opengraph contains unsupported fields "foo".
    Code
      data_open_graph_(list(foo = list(), bar = list()))
    Condition
      Warning in `data_open_graph_()`:
      In _pkgdown.yml, template.opengraph contains unsupported fields "foo" and "bar".
    Code
      data_open_graph_(list(twitter = 1))
    Condition
      Error in `data_open_graph_()`:
      ! In _pkgdown.yml, template.opengraph.twitter must be a list, not the number 1.
    Code
      data_open_graph_(list(twitter = list()))
    Condition
      Error in `data_open_graph_()`:
      ! In _pkgdown.yml, opengraph.twitter must include either creator or site.
    Code
      data_open_graph_(list(image = 1))
    Condition
      Error in `data_open_graph_()`:
      ! In _pkgdown.yml, template.opengraph.image must be a list, not the number 1.

