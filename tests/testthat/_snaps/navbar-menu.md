# can construct menu with children

    Code
      cat(navbar_html(menu))
    Output
      <li class="nav-item dropdown">
        <button class="nav-link dropdown-toggle" type="button" id="dropdown-title" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true">Title</button>
        <ul class="dropdown-menu" aria-labelledby="dropdown-title">
          <li><h6 class="dropdown-header" data-toc-skip>Heading</h6></li>
          <li><hr class="dropdown-divider"></li>
          <li><a class="dropdown-item" href="https://example.com">Link</a></li>
        </ul>
      </li>

# bad inputs give clear error

    Code
      navbar_html(1)
    Condition
      Error in `menu_type()`:
      ! Navbar components must be named lists, not the number 1.
    Code
      navbar_html(list(foo = 1))
    Condition
      Error in `menu_type()`:
      ! Unknown navbar component with names foo.
    Code
      navbar_html(submenu)
    Condition
      Error in `menu_type()`:
      ! Nested menus are not supported.

# can construct bullets

    Code
      cat(navbar_html(menu_icon("fa-question", "https://example.com", "label")))
    Output
      <li class="nav-item"><a class="nav-link" href="https://example.com" aria-label="label"><span class="fa fa-question"></span></a></li>
    Code
      cat(navbar_html(menu_heading("Hi")))
    Output
      <li class="nav-item"><h6 class="dropdown-header" data-toc-skip>Hi</h6></li>
    Code
      cat(navbar_html(menu_link("Hi", "https://example.com")))
    Output
      <li class="nav-item"><a class="nav-link" href="https://example.com">Hi</a></li>

# icons warn if no aria-label

    Code
      . <- navbar_html(menu_icon("fa-question", "https://example.com", NULL))
    Message
      x Icon "fa-question" lacks an `aria-label`.
      i Specify `aria-label` to make the icon accessible to screen readers.
      i Learn more in `vignette(pkgdown::accessibility)`.
      This message is displayed once every 8 hours.

# can construct theme menu

    Code
      cat(navbar_html(lightswitch))
    Output
      <li class="nav-item dropdown">
        <button class="nav-link dropdown-toggle" type="button" id="dropdown-lightswitch" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true" aria-label="Light switch"><span class="fa fa-sun"></span></button>
        <ul class="dropdown-menu" aria-labelledby="dropdown-lightswitch">
          <li><button class="dropdown-item" data-bs-theme-value="light"><span class="fa fa-sun"></span> Light</button></li>
          <li><button class="dropdown-item" data-bs-theme-value="dark"><span class="fa fa-moon"></span> Dark</button></li>
          <li><button class="dropdown-item" data-bs-theme-value="auto"><span class="fa fa-adjust"></span> Auto</button></li>
        </ul>
      </li>

# simple components don't change without warning

    Code
      cat(navbar_html(menu_heading("a")))
    Output
      <li class="nav-item"><h6 class="dropdown-header" data-toc-skip>a</h6></li>
    Code
      cat(navbar_html(menu_link("a", "b")))
    Output
      <li class="nav-item"><a class="nav-link" href="b">a</a></li>
    Code
      cat(navbar_html(menu_separator()))
    Output
      <li class="nav-item"><hr class="dropdown-divider"></li>
    Code
      cat(navbar_html(menu_search()))
    Output
      <li class="nav-item"><form class="form-inline" role="search">
       <input class="form-control" type="search" name="search-input" id="search-input" autocomplete="off" aria-label="Search site" placeholder="Search for" data-search-index="search.json"> 
      </form></li>

