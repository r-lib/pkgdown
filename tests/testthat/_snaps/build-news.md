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

# multi-page news are rendered [plain]

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
      Writing news/news-2.0.html
      Writing news/news-1.1.html
      Writing news/news-1.0.html
      Writing news/index.html

# multi-page news are rendered [ansi]

    Code
      data_news(pkg)[c("version", "page", "anchor")]
    Output
      [90m# A tibble: 4 x 3[39m
        version page  anchor         
        [3m[90m<chr>[39m[23m   [3m[90m<chr>[39m[23m [3m[90m<chr>[39m[23m          
      [90m1[39m 2.0     2.0   testpackage-20 
      [90m2[39m 1.1     1.1   testpackage-11 
      [90m3[39m 1.0.1   1.0   testpackage-101
      [90m4[39m 1.0.0   1.0   testpackage-100

---

    Code
      build_news(pkg)
    Message
      [1m[22mWriting [1m[36mnews/news-2.0.html[39m[22m
      [1m[22mWriting [1m[36mnews/news-1.1.html[39m[22m
      [1m[22mWriting [1m[36mnews/news-1.0.html[39m[22m
      [1m[22mWriting [1m[36mnews/index.html[39m[22m

# multi-page news are rendered [unicode]

    Code
      data_news(pkg)[c("version", "page", "anchor")]
    Output
      # A tibble: 4 × 3
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
      Writing news/news-2.0.html
      Writing news/news-1.1.html
      Writing news/news-1.0.html
      Writing news/index.html

# multi-page news are rendered [fancy]

    Code
      data_news(pkg)[c("version", "page", "anchor")]
    Output
      [90m# A tibble: 4 × 3[39m
        version page  anchor         
        [3m[90m<chr>[39m[23m   [3m[90m<chr>[39m[23m [3m[90m<chr>[39m[23m          
      [90m1[39m 2.0     2.0   testpackage-20 
      [90m2[39m 1.1     1.1   testpackage-11 
      [90m3[39m 1.0.1   1.0   testpackage-101
      [90m4[39m 1.0.0   1.0   testpackage-100

---

    Code
      build_news(pkg)
    Message
      [1m[22mWriting [1m[36mnews/news-2.0.html[39m[22m
      [1m[22mWriting [1m[36mnews/news-1.1.html[39m[22m
      [1m[22mWriting [1m[36mnews/news-1.0.html[39m[22m
      [1m[22mWriting [1m[36mnews/index.html[39m[22m

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

