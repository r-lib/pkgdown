/**
 * We need to do this so that the version dropdown doesn't used cached HTML
 */
$(window).bind("pageshow", function(event) {
  if (event.originalEvent.persisted) {
    window.location.reload()
  }
});

$(document).ready(function () {

/**
 * This replaces the package version number in the docs with a
 * dropdown where you can select the version of the docs to view.
 */

  // Load JSON file mapping between docs version and R package version
  $.getJSON(window.location.origin + "/versions.json", function( data ) {
    // get the current page's version number:
    var displayed_version = $('.version').text().trim();
    // Create a dropdown selector and add the appropriate attributes
    const sel = document.createElement("select");
    sel.name = "version-selector";
    sel.id = "version-selector";
    sel.classList.add("navbar-default");
    // When the selected value is changed, take the user to the version
    // of the page they are browsing in the selected version
    sel.onchange = function(){
     if (this.value) window.location.href=this.value;
    }

    // For each of the items in the JSON object (name/version pairs)
    $.each( data, function( key, val ) {
      // Add a new option to the dropdown selector
      const opt = document.createElement("option");
      // Set value to the path and the fallback path
      opt.value = window.location.origin + val.path;
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


