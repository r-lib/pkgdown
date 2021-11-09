/* http://gregfranko.com/blog/jquery-best-practices/ */
(function($) {
  $(function() {
    Toc.init({
      $nav: $("#toc"),
      $scope: $(".contents h2, .contents h3, .contents h4, .contents h5,.contents h6")
    });
    $('body').scrollspy({
      target: '#toc',
      offset: 56 // headroom height
    });
});
})(window.jQuery || window.$)


