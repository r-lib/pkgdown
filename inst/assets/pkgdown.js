(function() {
  // use noConflict to avoid dependency conflict with htmlwidgets used in examples
  var jQuery = $.noConflict(false);
  jQuery(function() {
    jQuery("#sidebar").stick_in_parent({offset_top: 40});
    jQuery('body').scrollspy({
      target: '#sidebar',
      offset: 60
    });
  });
})();
