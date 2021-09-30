HTMLWidgets.widget({

  name: 'visual_diff',

  type: 'output',

  factory: function(el, width, height) {

    var dv = diffviewer.init(el);

    return {
      renderValue: function(x) {
        dv.render(x);
      },

      resize: function(width, height) {
      },

      dv: dv

    };
  }
});
