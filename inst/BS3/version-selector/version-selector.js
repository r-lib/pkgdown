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

  const path_to_try = event.target.value;

  const base_path = path_to_try.match("(.*\/r\/)?")[0];
  let try_url = path_to_try;
  $.ajax({
      type: 'HEAD',
      url: try_url,
      success: function() {
          location.href = try_url;
      }
  }).fail(function() {
      location.href = base_path;
  });
  return false;
}

(function () {

  $(document).ready(function () {

  /**
   * This replaces the package version number in the docs with a
   * dropdown where you can select the version of the docs to view.
   */

     // Get the start of the path which includes the version number or "dev"
     // where applicable and add the "/docs/" suffix
    $pathStart = function(){
      return window.location.origin + "/docs/";
    }

    // Get the end of the path after the version number or "dev" if present
    $pathEnd  = function(){
      var current_path = window.location.pathname;
      return current_path.match("(?<=\/r).*");
    }

    // Load JSON file mapping between docs version and R package version
    $.getJSON("https://arrow.apache.org/docs/r/versions.json", function( data ) {
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
        // Set the path based on the 'version' field
        opt.value = $pathStart() + val.version + "r" + $pathEnd();
        // Set the currently selected item based on the major and minor version numbers
        opt.selected = val.name.match("[0-9.]*")[0] === displayed_version;
        // Set the displayed text based on the 'name' field
        opt.text = val.name;
        // Add to the selector
        sel.append(opt);
      });

      // Replace the HTML "version" component with the new selector
      $("span.version").replaceWith(sel);
    });
});


})();

