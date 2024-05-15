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
      <input type="search" class="form-control" name="search-input" id="search-input" autocomplete="off" aria-label="Search site" placeholder="Search for" data-search-index="search.json">
      </form></li>

