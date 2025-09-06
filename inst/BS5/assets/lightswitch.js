
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

function bsSetupThemeToggle() {
  'use strict'

  const showActiveTheme = (theme, focus = false) => {
    var activeLabel, activeIcon;

    document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
      const buttonTheme = element.getAttribute('data-bs-theme-value')
      const isActive = buttonTheme == theme

      element.classList.toggle('active', isActive)
      element.setAttribute('aria-pressed', isActive)

      if (isActive) {
        activeLabel = element.textContent;
        activeIcon = element.querySelector('span').classList.value;
      }
    })

    const themeSwitcher = document.querySelector('#dropdown-lightswitch')
    if (!themeSwitcher) {
      return
    }

    themeSwitcher.setAttribute('aria-label', activeLabel)
    themeSwitcher.querySelector('span').classList.value = activeIcon;

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

    document
      .querySelectorAll('[data-bs-theme-value]')
      .forEach(toggle => {
        toggle.addEventListener('click', () => {
          const theme = toggle.getAttribute('data-bs-theme-value')
          setTheme(theme)
          setStoredTheme(theme)
          showActiveTheme(theme, true)
        })
      })
  })
}

setTheme(getPreferredTheme());
bsSetupThemeToggle();

/* inst/pkgdown/assets/autobrand.js */

// Matrix multiplication helper
function multiplyMatrices(a, b) {
  const result = [];
  for (let i = 0; i < 4; i++) {
    result[i] = [];
    for (let j = 0; j < 5; j++) {
      result[i][j] = 0;
      for (let k = 0; k < 4; k++) {
        result[i][j] += a[i][k] * b[k][j];
      }
      if (j < 4) {
        result[i][j] += a[i][4] * (j === i ? 1 : 0);
      } else {
        result[i][j] += a[i][4];
      }
    }
  }
  return result;
}

// Create the autobrand filter matrix
function createAutobrandMatrix(bgColor, fgColor) {
  // Normalize colors to 0-1 range
  const bg = bgColor.map(c => c / 255);
  const fg = fgColor.map(c => c / 255);

  // Check if we need to flip (dark mode)
  const bgLuminance = 0.299 * bg[0] + 0.587 * bg[1] + 0.114 * bg[2];
  const fgLuminance = 0.299 * fg[0] + 0.587 * fg[1] + 0.114 * fg[2];
  const needsFlip = bgLuminance < fgLuminance;

  if (needsFlip) {
    // We need to compose multiple transformations
    // This is a simplified version - in practice you'd want the full
    // RGB->XYZ->shear->flip->unshear->XYZ->RGB transformation
    return [
      [-1, 0, 0, 0, 1],
      [0, -1, 0, 0, 1],
      [0, 0, -1, 0, 1],
      [0, 0, 0, 1, 0]
    ];
  } else {
    // Simple interpolation for light mode
    const matrix = [];
    for (let i = 0; i < 3; i++) {
      matrix[i] = [
        fg[i] - bg[i], 0, 0, 0, bg[i]
      ];
    }
    matrix[3] = [0, 0, 0, 1, 0]; // Alpha channel unchanged
    return matrix;
  }
}

// Inject SVG filters into the page
function injectAutobrandFilters() {
  // Get theme colors from CSS custom properties
  const style = getComputedStyle(document.documentElement);
  const bgColor = style.getPropertyValue('--autobrand-bg').split(',').map(c => parseInt(c.trim()));
  const fgColor = style.getPropertyValue('--autobrand-fg').split(',').map(c => parseInt(c.trim()));

  // Create SVG filter element
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('class', 'autobrand-filters');
  svg.innerHTML = `
    <defs>
      <filter id="autobrand-dark" color-interpolation-filters="sRGB">
        <feColorMatrix type="matrix" values="${createAutobrandMatrix(bgColor, fgColor).flat().join(' ')}" />
      </filter>
    </defs>
  `;

  // Add to document
  document.body.appendChild(svg);
}

// Initialize on DOM ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', injectAutobrandFilters);
} else {
  injectAutobrandFilters();
}

// Re-inject on theme change
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
  document.querySelector('.autobrand-filters')?.remove();
  injectAutobrandFilters();
});
