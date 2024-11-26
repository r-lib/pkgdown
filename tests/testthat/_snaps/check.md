# sitrep complains about BS3

    Code
      pkgdown_sitrep(pkg)
    Message
      -- Sitrep ----------------------------------------------------------------------
      x Bootstrap 3 is deprecated; please switch to Bootstrap 5.
      i Learn more at <https://www.tidyverse.org/blog/2021/12/pkgdown-2-0-0/#bootstrap-5>.
      v URLs ok.
      v Favicons ok.
      v Open graph metadata ok.
      v Articles metadata ok.
      v Reference metadata ok.

# sitrep reports all problems

    Code
      pkgdown_sitrep(pkg)
    Message
      -- Sitrep ----------------------------------------------------------------------
      x URLs not ok.
        In DESCRIPTION, URL is missing package url (http://test.org).
        See details in `vignette(pkgdown::metadata)`.
      v Favicons ok.
      v Open graph metadata ok.
      v Articles metadata ok.
      x Reference metadata not ok.
        In _pkgdown.yml, 1 topic missing from index: "?".
        Either add to the reference index, or use `@keywords internal` to drop from the index.

# checks fails on first problem

    Code
      check_pkgdown(pkg)
    Condition
      Error in `check_pkgdown()`:
      ! In DESCRIPTION, URL is missing package url (http://test.org).
      i See details in `vignette(pkgdown::metadata)`.

# both inform if everything is ok

    Code
      pkgdown_sitrep(pkg)
    Message
      -- Sitrep ----------------------------------------------------------------------
      v URLs ok.
      v Favicons ok.
      v Open graph metadata ok.
      v Articles metadata ok.
      v Reference metadata ok.
    Code
      check_pkgdown(pkg)
    Message
      v No problems found.

# check_urls reports problems

    Code
      check_urls(pkg)
    Condition
      Error:
      ! In _pkgdown.yml, url is missing.
      i See details in `vignette(pkgdown::metadata)`.

---

    Code
      check_urls(pkg)
    Condition
      Error:
      ! In DESCRIPTION, URL is missing package url (https://testpackage.r-lib.org).
      i See details in `vignette(pkgdown::metadata)`.

# check_favicons reports problems

    Code
      check_favicons(pkg)
    Condition
      Error in `check_favicons()`:
      ! Found package logo but not favicons.
      i Do you need to run `build_favicons()`?

---

    Code
      check_favicons(pkg)
    Condition
      Error in `check_favicons()`:
      ! Package logo is newer than favicons.
      i Do you need to rerun `build_favicons()`?

