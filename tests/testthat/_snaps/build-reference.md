# parse failures include file name [plain]

    Code
      build_reference(pkg)
    Condition
      Error in `purrr::map()`:
      i In index: 1.
      i With name: f.Rd.
      Caused by error in `.f()`:
      ! Failed to parse Rd in f.Rd
      In index: 4.
      Caused by error in `purrr::map()`:
      i In index: 4.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\url{}`.
      x Check for empty \url{} tags.

# parse failures include file name [ansi]

    Code
      build_reference(pkg)
    Condition
      [1m[33mError[39m in `purrr::map()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [36mi[39m With name: f.Rd.
      [1mCaused by error in `.f()`:[22m
      [33m![39m Failed to parse Rd in f.Rd
      In index: 4.
      [1mCaused by error in `purrr::map()`:[22m
      [1m[22m[36mi[39m In index: 4.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\url{}`.
      [31mx[39m Check for empty \url{} tags.

# parse failures include file name [unicode]

    Code
      build_reference(pkg)
    Condition
      Error in `purrr::map()`:
      ℹ In index: 1.
      ℹ With name: f.Rd.
      Caused by error in `.f()`:
      ! Failed to parse Rd in f.Rd
      In index: 4.
      Caused by error in `purrr::map()`:
      ℹ In index: 4.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag `\url{}`.
      ✖ Check for empty \url{} tags.

# parse failures include file name [fancy]

    Code
      build_reference(pkg)
    Condition
      [1m[33mError[39m in `purrr::map()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [36mℹ[39m With name: f.Rd.
      [1mCaused by error in `.f()`:[22m
      [33m![39m Failed to parse Rd in f.Rd
      In index: 4.
      [1mCaused by error in `purrr::map()`:[22m
      [1m[22m[36mℹ[39m In index: 4.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag `\url{}`.
      [31m✖[39m Check for empty \url{} tags.

# test usage ok on rendered page [plain]

    Code
      build_reference(pkg, topics = "c")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "c")

# test usage ok on rendered page [ansi]

    Code
      build_reference(pkg, topics = "c")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "c")

# test usage ok on rendered page [unicode]

    Code
      build_reference(pkg, topics = "c")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "c")

# test usage ok on rendered page [fancy]

    Code
      build_reference(pkg, topics = "c")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "c")

# .Rd without usage doesn't get Usage section [plain]

    Code
      build_reference(pkg, topics = "e")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "e")

# .Rd without usage doesn't get Usage section [ansi]

    Code
      build_reference(pkg, topics = "e")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "e")

# .Rd without usage doesn't get Usage section [unicode]

    Code
      build_reference(pkg, topics = "e")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "e")

# .Rd without usage doesn't get Usage section [fancy]

    Code
      build_reference(pkg, topics = "e")

---

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "e")

# pkgdown html dependencies are suppressed from examples in references

    Code
      init_site(pkg)

---

    Code
      build_reference(pkg, topics = "a")

