# data_news works as expected for h1 & h2

    # A tibble: 2 x 3
      version    page  anchor             
      <chr>      <chr> <chr>              
    1 1.0.0.9000 dev   testpackage-1009000
    2 1.0.0      1.0   testpackage-100    

---

    # A tibble: 2 x 3
      version    page  anchor             
      <chr>      <chr> <chr>              
    1 1.0.0.9000 dev   testpackage-1009000
    2 1.0.0      1.0   testpackage-100    

# multi-page news are rendered

    Code
      data_news(pkg)[c("version", "page", "anchor")]
    Output
      # A tibble: 4 x 3
        version page  anchor         
        <chr>   <chr> <chr>          
      1 2.0     2.0   testpackage-20 
      2 1.1     1.1   testpackage-11 
      3 1.0.1   1.0   testpackage-101
      4 1.0.0   1.0   testpackage-100

---

    Code
      build_news(pkg)
    Message
      -- Building news ---------------------------------------------------------------
      Writing `news/news-2.0.html`
      Writing `news/news-1.1.html`
      Writing `news/news-1.0.html`
      Writing `news/index.html`

# news headings get class and release date

    <div>
      <h2 class="page-header" data-toc-text="1.0">
        <small>2020-01-01</small>
      </h2>
    </div>

---

    <div>
      <h2 class="pkg-version" data-toc-text="1.0"/>
      <p class="text-muted">CRAN release: 2020-01-01</p>
    </div>

# clear error for bad hierarchy - bad nesting

    Invalid NEWS.md: inconsistent use of section headings.
    i Top-level headings must be either all <h1> or all <h2>.
    i See `?pkgdown::build_news()` for more details.

# clear error for bad hierarchy - h3

    Invalid NEWS.md: inconsistent use of section headings.
    i Top-level headings must be either all <h1> or all <h2>.
    i See `?pkgdown::build_news()` for more details.

# news can contain footnotes

    Code
      x <- data_news(pkg)
    Condition
      Warning:
      Footnotes in NEWS.md are not currently supported

# data_news warns if no headings found

    Code
      . <- data_news(pkg)
    Condition
      Warning:
      No version headings found in NEWS.md
      i See `?pkgdown::build_news()` for expected structure.

