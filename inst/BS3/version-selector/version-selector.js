/**
 * We need to do this so that the version dropdown doesn't used cached HTML
 */
$(window).bind("pageshow", function(event) {
  if (event.originalEvent.persisted) {
    window.location.reload()
  }
});

/**
 * Check if the page to be browsed to exists and if not, redirect to base path
 */
function check_page_exists_and_redirect(event) {

  const urls = event.target.value.split(",")
  const path_to_try = urls[0];
  const fallback_path = urls[1]

  $.ajax({
      type: 'HEAD',
      url: path_to_try,
      success: function() {
          location.href = path_to_try;
      }
  }).fail(function() {
      location.href = fallback_path;
  });
  return false;
}

(function () {

  $(document).ready(function () {

  /**
   * This replaces the package version number in the docs with a
   * dropdown where you can select the version of the docs to view.
   */

    // Load JSON file mapping between docs version and R package version
    $.getJSON(window.location.origin + "/versions.json", function( data ) {
      // get the current page's version number:
      var displayed_version = $('.version').text();
      // Create a dropdown selector and add the appropriate attributes
      const sel = document.createElement("select");
      sel.name = "version-selector";
      sel.id = "version-selector";
      sel.classList.add("navbar-default");
      // When the selected value is changed, take the user to the version
      // of the page they are browsing in the selected version
      sel.onchange = check_page_exists_and_redirect;

      // For each of the items in the JSON object (name/version pairs)
      $.each( data, function( key, val ) {
        // Add a new option to the dropdown selector
        const opt = document.createElement("option");
        // Get the final component of the path
        const pathEnd = window.location.pathname.replace(val.path, "");
        // Set the path based on the 'path' field
        const base_path = window.location.origin + val.path;
        opt.value = [base_path + pathEnd, base_path];
        // Set the currently selected item based on the major and minor version numbers
        opt.selected = val.version === displayed_version;
        // Set the displayed text based on the 'label' field
        opt.text = val.label;
        // Add to the selector
        sel.append(opt);
      });

      // Replace the HTML "version" component with the new selector
      $("span.version").replaceWith(sel);
    });
  });
})();
