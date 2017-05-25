jQuery_3_1_0(function() {
  jQuery_3_1_0("#sidebar").stick_in_parent({offset_top: 40});
  jQuery_3_1_0('body').scrollspy({
    target: '#sidebar',
    offset: 60
  });

});
