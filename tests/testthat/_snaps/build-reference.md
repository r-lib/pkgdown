# parse failures include file name [plain]

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
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag "\\url{}".
      x Check for empty \url{} tags.

# parse failures include file name [ansi]

    Code
      build_reference(pkg)
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/f.Rd[39m[22m
    Condition
      [1m[33mError[39m in `purrr::map()`:[22m
      [1m[22m[36mi[39m In index: 1.
      [36mi[39m With name: f.Rd.
      [1mCaused by error in `.f()`:[22m
      [1m[22m[33m![39m Failed to parse Rd in [34mf.Rd[39m
      [1mCaused by error in `purrr::map()`:[22m
      [1m[22m[36mi[39m In index: 4.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag [34m"\\url{}"[39m.
      [31mx[39m Check for empty \url{} tags.

# parse failures include file name [unicode]

    Code
      build_reference(pkg)
    Message
      Writing reference/index.html
      Reading man/f.Rd
    Condition
      Error in `purrr::map()`:
      ℹ In index: 1.
      ℹ With name: f.Rd.
      Caused by error in `.f()`:
      ! Failed to parse Rd in 'f.Rd'
      Caused by error in `purrr::map()`:
      ℹ In index: 4.
      Caused by error in `stop_bad_tag()`:
      ! Failed to parse tag "\\url{}".
      ✖ Check for empty \url{} tags.

# parse failures include file name [fancy]

    Code
      build_reference(pkg)
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/f.Rd[39m[22m
    Condition
      [1m[33mError[39m in `purrr::map()`:[22m
      [1m[22m[36mℹ[39m In index: 1.
      [36mℹ[39m With name: f.Rd.
      [1mCaused by error in `.f()`:[22m
      [1m[22m[33m![39m Failed to parse Rd in [34mf.Rd[39m
      [1mCaused by error in `purrr::map()`:[22m
      [1m[22m[36mℹ[39m In index: 4.
      [1mCaused by error in `stop_bad_tag()`:[22m
      [1m[22m[33m![39m Failed to parse tag [34m"\\url{}"[39m.
      [31m✖[39m Check for empty \url{} tags.

# test usage ok on rendered page [plain]

    Code
      build_reference(pkg, topics = "c")
    Message
      Writing reference/index.html
      Reading man/c.Rd
      Writing reference/c.html

---

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      build_reference(pkg, topics = "c")
    Message
      Writing reference/index.html
      Reading man/c.Rd
      Writing reference/c.html

# test usage ok on rendered page [ansi]

    Code
      build_reference(pkg, topics = "c")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/c.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/c.html[39m[22m

---

    Code
      init_site(pkg)
    Message
      [1m[22mCopying [1m[32m../../../../inst/BS5/assets/link.svg[39m[22m and [1m[32m../../../../inst/BS5/assets/pkgdown.js[39m[22m
      to [1m[36mlink.svg[39m[22m and [1m[36mpkgdown.js[39m[22m

---

    Code
      build_reference(pkg, topics = "c")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/c.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/c.html[39m[22m

# test usage ok on rendered page [unicode]

    Code
      build_reference(pkg, topics = "c")
    Message
      Writing reference/index.html
      Reading man/c.Rd
      Writing reference/c.html

---

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      build_reference(pkg, topics = "c")
    Message
      Writing reference/index.html
      Reading man/c.Rd
      Writing reference/c.html

# test usage ok on rendered page [fancy]

    Code
      build_reference(pkg, topics = "c")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/c.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/c.html[39m[22m

---

    Code
      init_site(pkg)
    Message
      [1m[22mCopying [1m[32m../../../../inst/BS5/assets/link.svg[39m[22m and [1m[32m../../../../inst/BS5/assets/pkgdown.js[39m[22m
      to [1m[36mlink.svg[39m[22m and [1m[36mpkgdown.js[39m[22m

---

    Code
      build_reference(pkg, topics = "c")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/c.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/c.html[39m[22m

# .Rd without usage doesn't get Usage section [plain]

    Code
      build_reference(pkg, topics = "e")
    Message
      Writing reference/index.html
      Reading man/e.Rd
      Writing reference/e.html

---

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      build_reference(pkg, topics = "e")
    Message
      Writing reference/index.html
      Reading man/e.Rd
      Writing reference/e.html

# .Rd without usage doesn't get Usage section [ansi]

    Code
      build_reference(pkg, topics = "e")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/e.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/e.html[39m[22m

---

    Code
      init_site(pkg)
    Message
      [1m[22mCopying [1m[32m../../../../inst/BS5/assets/link.svg[39m[22m and [1m[32m../../../../inst/BS5/assets/pkgdown.js[39m[22m
      to [1m[36mlink.svg[39m[22m and [1m[36mpkgdown.js[39m[22m

---

    Code
      build_reference(pkg, topics = "e")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/e.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/e.html[39m[22m

# .Rd without usage doesn't get Usage section [unicode]

    Code
      build_reference(pkg, topics = "e")
    Message
      Writing reference/index.html
      Reading man/e.Rd
      Writing reference/e.html

---

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      build_reference(pkg, topics = "e")
    Message
      Writing reference/index.html
      Reading man/e.Rd
      Writing reference/e.html

# .Rd without usage doesn't get Usage section [fancy]

    Code
      build_reference(pkg, topics = "e")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/e.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/e.html[39m[22m

---

    Code
      init_site(pkg)
    Message
      [1m[22mCopying [1m[32m../../../../inst/BS5/assets/link.svg[39m[22m and [1m[32m../../../../inst/BS5/assets/pkgdown.js[39m[22m
      to [1m[36mlink.svg[39m[22m and [1m[36mpkgdown.js[39m[22m

---

    Code
      build_reference(pkg, topics = "e")
    Message
      [1m[22mWriting [1m[36mreference/index.html[39m[22m
      [1m[22mReading [1m[32mman/e.Rd[39m[22m
      [1m[22mWriting [1m[36mreference/e.html[39m[22m

# pkgdown html dependencies are suppressed from examples in references

    Code
      init_site(pkg)
    Message
      Copying ../../../../inst/BS5/assets/link.svg and ../../../../inst/BS5/assets/pkgdown.js
      to link.svg and pkgdown.js

---

    Code
      build_reference(pkg, topics = "a")
    Message
      Writing reference/index.html
      Reading man/a.Rd
      Writing reference/a.html

