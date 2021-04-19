/* http://gregfranko.com/blog/jquery-best-practices/ */
(function($) {
  $(function() {

    $('nav.navbar').headroom();

    $('body').scrollspy({
      target: '#sidebar',
      offset: 60
    });

    Toc.init({
      $nav: $("#toc"),
      $scope: $("h2, h3, h4, h5, h6")
    });

    // Activate popovers
    $('[data-toggle="popover"]').popover({
      container: 'body',
      html: true,
      trigger: 'focus',
      placement: "top",
      sanitize: false,
    });

    $('[data-toggle="tooltip"]').tooltip();

  /* Clipboard --------------------------*/

  function changeTooltipMessage(element, msg) {
    var tooltipOriginalTitle=element.getAttribute('data-original-title');
    element.setAttribute('data-original-title', msg);
    $(element).tooltip('show');
    element.setAttribute('data-original-title', tooltipOriginalTitle);
  }

  if(ClipboardJS.isSupported()) {
    $(document).ready(function() {
      var copyButton = "<button type='button' class='btn btn-primary btn-copy-ex' title='Copy to clipboard' aria-label='Copy to clipboard' data-toggle='tooltip' data-placement='left' data-trigger='hover' data-clipboard-copy><i class='fa fa-copy'></i></button>";

      $(".examples, div.sourceCode").addClass("hasCopyButton");

      // Insert copy buttons:
      $(copyButton).prependTo(".hasCopyButton");

      // Initialize tooltips:
      $('.btn-copy-ex').tooltip({container: 'body'});

      // Initialize clipboard:
      var clipboard = new ClipboardJS('[data-clipboard-copy]', {
        text: function(trigger) {
          return trigger.parentNode.textContent;
        }
      });

      clipboard.on('success', function(e) {
        changeTooltipMessage(e.trigger, 'Copied!');
        e.clearSelection();
      });

      clipboard.on('error', function() {
        changeTooltipMessage(e.trigger,'Press Ctrl+C or Command+C to copy');
      });

    });
  }
  });
})(window.jQuery || window.$)
