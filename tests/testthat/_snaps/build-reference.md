# parse failures include file name

    Code
      build_reference(pkg)
    Message
      Writing reference/index.html
      Reading man/f.Rd
    Condition
      Error in `purrr::map()`:
      i In index: 1.
      i With name: f.Rd.
      Caused by error in `.f()`:
      ! Failed to parse Rd in 'f.Rd'
      Caused by error in `purrr::map()`:
      i In index: 4.
      Caused by error:
      ! Failed to parse tag "\\url{}".
      i Check for empty \url{} tags.

# .Rd without usage doesn't get Usage section

    Code
      build_reference(pkg, topics = "e")
    Message
      Writing reference/index.html
      Reading man/e.Rd
      Writing reference/e.html

---

    Code
      build_reference(pkg, topics = "e")
    Message
      Writing reference/index.html
      Reading man/e.Rd
      Writing reference/e.html

# pkgdown html dependencies are suppressed from examples in references

    Code
      build_reference(pkg, topics = "a")
    Message
      Writing reference/index.html
      Reading man/a.Rd
      Writing reference/a.html

# examples are reproducible by default, i.e. 'seed' is respected

    Code
      build_reference(pkg, topics = "f")
    Message
      Writing reference/index.html
      Reading man/f.Rd
      Writing reference/f.html

---

    Code
      gsub("\\s+", " ", x = rvest::html_text(rvest::html_node(xml2::read_html(
        file.path(pkg$dst_path, "reference", "f.html")),
      "div#ref-examples div.sourceCode")))
    Output
      [1] "testpackage:::f() #> [1] 0.080750138 0.834333037 0.600760886 0.157208442 0.007399441 0.466393497 #> [7] 0.497777389 0.289767245 0.732881987 0.772521511 0.874600661 0.174940627 #> [13] 0.034241333 0.320385731 0.402328238 0.195669835 0.403538117 0.063661457 #> [19] 0.388701313 0.975547835 "

