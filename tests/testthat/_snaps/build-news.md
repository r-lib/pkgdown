# data_news works as expected - h1

    Code
      data_news(temp_pkg)
    Output
      # A tibble: 2 x 4
        version    page  anchor              html                                     
        <chr>      <chr> <chr>               <chr>                                    
      1 1.0.0.9000 dev   testpackage-1009000 "<div id=\"testpackage-1009000\" class=\~
      2 1.0.0      1.0   testpackage-100     "<div id=\"testpackage-100\" class=\"sec~

# data_news works as expected - h2

    Code
      data_news(temp_pkg)
    Output
      # A tibble: 2 x 4
        version    page  anchor              html                                     
        <chr>      <chr> <chr>               <chr>                                    
      1 1.0.0.9000 dev   changes-in-v1009000 "<div id=\"changes-in-v1009000\" class=\~
      2 1.0.0      1.0   changes-in-v100     "<div id=\"changes-in-v100\" class=\"sec~

# multi-page news are rendered

    # A tibble: 4 x 4
      version page  anchor          html                                            
      <chr>   <chr> <chr>           <chr>                                           
    1 2.0     2.0   testpackage-20  "<div id=\"testpackage-20\" class=\"section lev~
    2 1.1     1.1   testpackage-11  "<div id=\"testpackage-11\" class=\"section lev~
    3 1.0.1   1.0   testpackage-101 "<div id=\"testpackage-101\" class=\"section le~
    4 1.0.0   1.0   testpackage-100 "<div id=\"testpackage-100\" class=\"section le~

---

    -- Building news ---------------------------------------------------------------
    Writing 'news/news-2.0.html'
    Writing 'news/news-1.1.html'
    Writing 'news/news-1.0.html'
    Writing 'news/index.html'

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

    Invalid NEWS.md: inconsistent use of headers for sections.
    i See ?build_news

# clear error for bad hierarchy - h3

    Invalid NEWS.md: no use of h1 or h2 headers for sections.
    i See ?build_news

