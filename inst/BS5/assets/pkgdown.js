/* http://gregfranko.com/blog/jquery-best-practices/ */
(function($) {
  $(function() {

    $('nav.navbar').headroom();

    Toc.init({
      $nav: $("#toc"),
      $scope: $("main h2, main h3, main h4, main h5, main h6")
    });

    if ($('#toc').length) {
      $('body').scrollspy({
        target: '#toc',
        offset: $("nav.navbar").outerHeight() + 1
      });
    }

    // Activate popovers
    $('[data-bs-toggle="popover"]').popover({
      container: 'body',
      html: true,
      trigger: 'focus',
      placement: "top",
      sanitize: false,
    });

    $('[data-bs-toggle="tooltip"]').tooltip();

  /* Clipboard --------------------------*/

  function changeTooltipMessage(element, msg) {
    var tooltipOriginalTitle=element.getAttribute('data-bs-original-title');
    element.setAttribute('data-bs-original-title', msg);
    $(element).tooltip('show');
    element.setAttribute('data-bs-original-title', tooltipOriginalTitle);
  }

  if(ClipboardJS.isSupported()) {
    $(document).ready(function() {
      var copyButton = "<button type='button' class='btn btn-primary btn-copy-ex' title='Copy to clipboard' aria-label='Copy to clipboard' data-toggle='tooltip' data-placement='left' data-trigger='hover' data-clipboard-copy><i class='fa fa-copy'></i></button>";

      $("div.sourceCode").addClass("hasCopyButton");

      // Insert copy buttons:
      $(copyButton).prependTo(".hasCopyButton");

      // Initialize tooltips:
      $('.btn-copy-ex').tooltip({container: 'body'});

      // Initialize clipboard:
      var clipboard = new ClipboardJS('[data-clipboard-copy]', {
        text: function(trigger) {
          return trigger.parentNode.textContent.replace(/\n#>[^\n]*/g, "");
        }
      });

      clipboard.on('success', function(e) {
        changeTooltipMessage(e.trigger, 'Copied!');
        e.clearSelection();
      });

      clipboard.on('error', function(e) {
        changeTooltipMessage(e.trigger,'Press Ctrl+C or Command+C to copy');
      });

    });
  }

    /* Search marking --------------------------*/
    var url = new URL(window.location.href);
    var toMark = url.searchParams.get("q");
    var mark = new Mark("main#main");
    if (toMark) {
      mark.mark(toMark, {
        accuracy: {
          value: "complementary",
          limiters: [",", ".", ":", "/"],
        }
      });
    }

  /* Search --------------------------*/
  /* Adapted from https://github.com/rstudio/bookdown/blob/2d692ba4b61f1e466c92e78fd712b0ab08c11d31/inst/resources/bs4_book/bs4_book.js#L25 */
    // Initialise search index on focus
  var fuse;
  $("#search-input").focus(async function(e) {
    if (fuse) {
      return;
    }

    $(e.target).addClass("loading");
    var response = await fetch($("#search-input").data("search-index"));
    var data = await response.json();

    var options = {
      keys: ["what", "text", "code"],
      ignoreLocation: true,
      threshold: 0.1,
      includeMatches: true,
      includeScore: true,
    };
    fuse = new Fuse(data, options);

    $(e.target).removeClass("loading");
  });

  // Use algolia autocomplete
  var options = {
    autoselect: true,
    debug: true,
    hint: false,
    minLength: 2,
  };
  var q;
async function searchFuse(query, callback) {
  await fuse;

  var items;
  if (!fuse) {
    items = [];
  } else {
    q = query;
    var results = fuse.search(query, { limit: 20 });
    items = results
      .filter((x) => x.score <= 0.75)
      .map((x) => x.item);
    if (items.length === 0) {
      items = [{dir:"Sorry 😿",previous_headings:"",title:"No results found.",what:"No results found.",path:window.location.href}];
    }
  }
  callback(items);
}
  $("#search-input").autocomplete(options, [
    {
      name: "content",
      source: searchFuse,
      templates: {
        suggestion: (s) => {
          if (s.title == s.what) {
            return `${s.dir} >	<div class="search-details"> ${s.title}</div>`;
          } else if (s.previous_headings == "") {
            return `${s.dir} >	<div class="search-details"> ${s.title}</div> > ${s.what}`;
          } else {
            return `${s.dir} >	<div class="search-details"> ${s.title}</div> > ${s.previous_headings} > ${s.what}`;
          }
        },
      },
    },
  ]).on('autocomplete:selected', function(event, s) {
    window.location.href = s.path + "?q=" + q + "#" + s.id;
  });
  });
})(window.jQuery || window.$)

/*!
 * Color mode toggler for Bootstrap's docs (https://getbootstrap.com/)
 * Copyright 2011-2023 The Bootstrap Authors
 * Licensed under the Creative Commons Attribution 3.0 Unported License.
 * Updates for {pkgdown} by the {bslib} authors, also licensed under CC-BY-3.0.
 */

const getStoredTheme = () => localStorage.getItem('theme')
const setStoredTheme = theme => localStorage.setItem('theme', theme)

const getPreferredTheme = () => {
  const storedTheme = getStoredTheme()
  if (storedTheme) {
    return storedTheme
  }

  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

const setTheme = theme => {
  if (theme === 'auto') {
    document.documentElement.setAttribute('data-bs-theme', (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'))
  } else {
    document.documentElement.setAttribute('data-bs-theme', theme)
  }
}

setTheme(getPreferredTheme())

function bsSetupThemeToggle () {
  'use strict'

  const showActiveTheme = (theme, focus = false) => {
    const themeSwitcher = document.querySelector('#bd-theme')

    if (!themeSwitcher) {
      return
    }

    const themeSwitcherText = document.querySelector('#bd-theme-text')
    const activeThemeIcon = document.querySelector('.theme-icon-active')
    const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`)
    const svgOfActiveBtn = btnToActive.querySelector('.theme-icon').innerHTML

    document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
      element.classList.remove('active')
      element.setAttribute('aria-pressed', 'false')
    })

    btnToActive.classList.add('active')
    btnToActive.setAttribute('aria-pressed', 'true')
    activeThemeIcon.innerHTML = svgOfActiveBtn
    const themeSwitcherLabel = `${themeSwitcherText.textContent} (${btnToActive.dataset.bsThemeValue})`
    themeSwitcher.setAttribute('aria-label', themeSwitcherLabel)

    if (focus) {
      themeSwitcher.focus()
    }
  }

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    const storedTheme = getStoredTheme()
    if (storedTheme !== 'light' && storedTheme !== 'dark') {
      setTheme(getPreferredTheme())
    }
  })

  window.addEventListener('DOMContentLoaded', () => {
    showActiveTheme(getPreferredTheme())

    document.querySelectorAll('[data-bs-theme-value]')
      .forEach(toggle => {
        toggle.addEventListener('click', () => {
          const theme = toggle.getAttribute('data-bs-theme-value')
          setStoredTheme(theme)
          setTheme(theme)
          showActiveTheme(theme, true)
        })
      })
  })
}

function colorPickerMarkup () {

  const icons = {
    "sun-fill": `<i class="bi bi-sun-fill"></i>`,
    "moon-stars-fill": `<i class="bi bi-moon-stars-fill"></i>`,
    "circle-half": `<i class="bi bi-circle-half"></i>`
  }

  return `<button class="btn btn-link nav-link py-2 px-0 px-lg-2 dropdown-toggle d-flex align-items-center" id="bd-theme" type="button" aria-expanded="false" data-bs-toggle="dropdown" data-bs-display="static" aria-label="Toggle theme (light)">
    <span class="theme-icon-active">${icons['sun-fill']}</span>
    <span class="d-lg-none ms-2" id="bd-theme-text">Toggle theme</span>
  </button>
  <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="bd-theme-text">
    <li>
      <button type="button" class="dropdown-item d-flex align-items-center active" data-bs-theme-value="light" aria-pressed="true">
        <span class="me-2 opacity-50 theme-icon">${icons['sun-fill']}</span>
        Light
        <svg class="bi ms-auto d-none"><use href="#check2"></use></svg>
      </button>
    </li>
    <li>
      <button type="button" class="dropdown-item d-flex align-items-center" data-bs-theme-value="dark" aria-pressed="false">
        <span class="me-2 opacity-50 theme-icon">${icons['moon-stars-fill']}</span>
        Dark
        <svg class="bi ms-auto d-none"><use href="#check2"></use></svg>
      </button>
    </li>
    <li>
      <button type="button" class="dropdown-item d-flex align-items-center" data-bs-theme-value="auto" aria-pressed="false">
        <span class="me-2 opacity-50 theme-icon">${icons['circle-half']}</span>
        Auto
        <svg class="bi ms-auto d-none"><use href="#check2"></use></svg>
      </button>
    </li>
  </ul>`
}

document.addEventListener('DOMContentLoaded', () => {
  const switcher = document.querySelector('.navbar [href$="#dark-mode"]')
  if (!switcher) return

  switcher.parentElement.classList.add('dropdown')
  switcher.parentElement.innerHTML = colorPickerMarkup()
  bsSetupThemeToggle()
})
