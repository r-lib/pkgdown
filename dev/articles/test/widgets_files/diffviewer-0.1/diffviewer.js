/*jshint
  undef:true,
  browser:true,
  devel: true,
  jquery:true,
  strict:false,
  curly:false,
  indent:2
*/
/*global diffviewer:true, HTMLWidgets, JsDiff, Diff2HtmlUI, resemble, daff, Papa, escape */

diffviewer = (function() {
  var diffviewer = {};

  var ZOOM_DEFAULT = 0.5;

  // If one of the files was an empty string, then it was likely a missing
  // file. For image diff to work, we need to use an image. This is a 1x1
  // PNG.
  var empty_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII=";

  diffviewer.init = function(el) {

    var dv = {
      el: el,
      id: el.id
    };

    dv.render = function(message) {

      var $el = $(dv.el);

      console.log(message);

      var result;

      if(message.typediff == "text") {

        console.log("TEXT!");

        result = create_text_diff($el, message.filename, message.old, message.new);

      } else if (message.typediff == "image") {

        console.log("IMAGE!");

        result = create_image_diff($el, message.filename, message.old, message.new);

      } else if (message.typediff == "data") {

        console.log("CSV");

        result = create_daff($el, message.filename, message.old, message.new);

      }

      console.log(result);

      /***
      var $toc = $("<div></div>");
      $el.append($toc);

      var results = message.diff_data.map(function(x, idx) {
        // Append element for current diff
        var diff_el = document.createElement("div");
        diff_el.id  = dv.id + "-file" + idx;
        dv.el.appendChild(diff_el);

        var res;
        if (is_text(x.old) && is_text(x.new)) {
          res = create_text_diff(diff_el, x.filename, x.old, x.new);

        } else if (is_image(x.old) && is_image(x.new)) {
          res = create_image_diff(diff_el, x.filename, x.old, x.new);

        }

        return res;
      });

      render_file_change_table($toc, dv.id, results);

      enable_expand_buttons(dv.el);

      ***/

    };

    return dv;
  };

  function is_text(str) {
    // If it's not base64 encoded, assume it's text.
    return str === null || !str.match(/^data:[^;]+;base64,/);
  }

  function is_image(str) {
    return str === null || str.match(/^data:image\/[^;]+;base64,/);
  }

  function b64_to_utf8( str ) {
    // https://www.sumitgupta.net/javascript-base64-encode-decode-for-utf-8unicode-string/
    return decodeURIComponent(escape(window.atob( str )));

  }

  function create_text_diff(el, filename, old_txt, new_txt, context = 5) {

    var state = {
      filename: filename,
      status: null
    };

    var status;
    if (old_txt === new_txt) {
      state.status = "same";
    } else if (old_txt === null) {
      old_txt = "";
      state.status = "added";
    } else if (new_txt === null) {
      new_txt = "";
      state.status = "removed";
    } else {
      state.status = "modified";
    }

    // check this
    var $el = $(el)[0];

    // Do diff
    var diff_str = JsDiff.createPatch(filename, old_txt, new_txt, "", "", { context: context});

    // Show diff
    var diff2htmlUi = new Diff2HtmlUI({ diff: diff_str });
    diff2htmlUi.draw("#" + $el.id, {
      showFiles: false
    });

    if (state.status === "same") {

      $("#" + $el.id)
        .find(".d2h-tag")
        .text("NOT CHANGED");

     // here we put the original file
      var tbl = $("#" + $el.id)
        .find(".d2h-diff-tbody");

      tbl.empty();

      var lines = old_txt.split("\n");

      lines.forEach(function(value, index){

        // console.log(value);
        // console.log(index);

        var mrkup =  '<tr>' +
        '<td class="d2h-code-linenumber d2h-cntx">' +
          '<div class="line-num1">' + (index + 1) + '</div>' +
         // '<div class="line-num2">22</div>' +
        '</td>' +
        '<td class="d2h-cntx">' +
          '<div class="d2h-code-line d2h-cntx">' +
            '<span class="d2h-code-line-prefix"> </span>' +
            '<span class="d2h-code-line-ctn">' + value + '</span>' +
          '</div>' +
          '</td>' +
       '</tr>';

        tbl.append(mrkup);

      });

    }

    if(state.status === "modified") {

      // add options to context buttons
      var spn = $(
        '<span class="link" style="cursor:default; position: absolute;right:10px;font-size:10px;color:#888">' +
          'context lines: <a style="cursor:pointer">5</a> <a style="cursor:pointer">10</a> <a style="cursor:pointer">50</a>' +
        '</span>'
        );

      $("#" + $el.id)
        .find(".d2h-file-name-wrapper")
        .append(spn);

      var as = $("#" + $el.id)
        .find(".link")
        .find("a");

      as.on("click", function(){

        console.log(this);

        create_text_diff(el, filename, old_txt, new_txt, this.text);

      });

    }

    return state;

  }

  function create_image_diff(el, filename, old_img, new_img) {

    var state = {
      filename: filename,
      status: null
    };

    el.addClass("diffviewer");

    if (old_img === new_img) {
      state.status = "same";
    } else if (old_img === null) {
      old_img = empty_png;
      state.status = "added";
    } else if (new_img === null) {
      new_img = empty_png;
      state.status = "removed";
    } else {
      state.status = "modified";
    }

    var $wrapper = $(
      '<div class="image-diff">' +
        '<div class="d2h-file-header">' +
          '<span class="d2h-file-name-wrapper">' +
            //'<span class="diff-expand-button"></span>' +
            '<span class="d2h-icon-wrapper">' +
              '<svg aria-hidden="true" class="d2h-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12">' +
                '<path d="M6 5H2v-1h4v1zM2 8h7v-1H2v1z m0 2h7v-1H2v1z m0 2h7v-1H2v1z m10-7.5v9.5c0 0.55-0.45 1-1 1H1c-0.55 0-1-0.45-1-1V2c0-0.55 0.45-1 1-1h7.5l3.5 3.5z m-1 0.5L8 2H1v12h10V5z">' +
                '</path>' +
                '</svg>' +
            '</span>' +
            '<span class="d2h-file-name"></span>' +
            '<span class="d2h-tag"></span>' +
          '</span>' +
        '</div>' +
        '<div class="image-diff-controls"></div>' +
        '<div class="image-diff-container">' +
        '</div>' +
      '</div>'
    );

    $wrapper.find(".d2h-file-name").text(filename);

    // change append to remove previous elements.
    $(el).html($wrapper);

    if (state.status === "same") {
      /***
      $wrapper.find(".diff-tag")
        .addClass("diff-same-tag")
        .text("NOT CHANGED");
      ***/

      $wrapper.find(".d2h-tag")
        .addClass("d2h-changed d2h-changed-tag")
        .text("NOT CHANGED");

    } else if (state.status === "modified") {
      /***
      $wrapper.find(".diff-tag")
        .addClass("diff-modified-tag")
        .text("MODIFIED");
      ***/

      $wrapper.find(".d2h-tag")
        .addClass("d2h-changed d2h-changed-tag")
        .text("CHANGED");

    } else if (state.status === "added") {
      $wrapper.find(".diff-tag")
        .addClass("diff-added-tag")
        .text("ADDED");

    } else if (state.status === "removed") {
      $wrapper.find(".diff-tag")
        .addClass("diff-removed-tag")
        .text("REMOVED");
    }

    $wrapper.find(".image-diff-controls")
      .html(
        '<span class="image-zoom-buttons">' +
          '<span class="image-diff-button image-diff-button-left" data-button="0.25">1:4</span>' +
          '<span class="image-diff-button image-diff-button-middle" data-button="0.5">1:2</span>' +
          '<span class="image-diff-button image-diff-button-middle" data-button="1">1:1</span>' +
          '<span class="image-diff-button image-diff-button-right" data-button="2">2:1</span>' +
        '</span>' +
        '<span class="image-diff-view-buttons"></span>' +
        '<span class="image-diff-controls-sub"></span>'
      );

    $wrapper
      .find(".image-diff-view-buttons")
      .html(generate_view_buttons(Views.summary()));

    var $container = $wrapper.find(".image-diff-container");
    var $controls = $wrapper.find(".image-diff-controls-sub");
    state.views = Views.create($container, $controls, old_img, new_img);

    // Zoom buttons
    $wrapper.on("mousedown", ".image-zoom-buttons > .image-diff-button", function(e) {
      if (e.which !== 1) return;

      var $el = $(this);
      if ($el.hasClass("image-diff-button-selected")) return;

      // Unselect sibling buttons and select this button.
      $el.siblings(".image-diff-button").removeClass("image-diff-button-selected");
      $el.addClass("image-diff-button-selected");

      var zoom_level = $el.data("button");
      state.views.zoom(zoom_level);
    });
    // Start with 1:2 button selected.
    // Note that the value should match ZOOM_DEFAULT.
    $wrapper.find(".image-zoom-buttons > .image-diff-button:nth-child(2)").trigger({
      type: "mousedown",
      which: 1
    });

    // View buttons
    $wrapper.on("mousedown", ".image-diff-view-buttons > .image-diff-button", function(e) {
      if (e.which !== 1) return;

      var $el = $(this);
      if ($el.hasClass("image-diff-button-selected")) return;

      // Unselect sibling buttons and select this button.
      $el.siblings(".image-diff-button").removeClass("image-diff-button-selected");
      $el.addClass("image-diff-button-selected");

      var button_type = $el.data("button");

      state.views.activate(button_type);
    });

    // Start with first button selected
    $wrapper.find(".image-diff-view-buttons > .image-diff-button:first").trigger({
      type: "mousedown",
      which: 1            // Simulate left button
    });

    return state;
  }

  function create_daff(el, filename, old_csv, new_csv) {

    var state = {
      filename: filename,
      status: null
    };

    if (old_csv === new_csv) {
      state.status = "same";
    } else {
      state.status = "modified";
    }

    old_csv = old_csv.replace("data:text/csv;base64,", "");
    new_csv = new_csv.replace("data:text/csv;base64,", "");

    var old_arr = Papa.parse(b64_to_utf8(old_csv), {skipEmptyLines : true}).data;
    var new_arr = Papa.parse(b64_to_utf8(new_csv), {skipEmptyLines : true}).data;

    // from https://github.com/paulfitz/daff#the-library

    var table1 = new daff.TableView(old_arr);
    var table2 = new daff.TableView(new_arr);

    var alignment = daff.compareTables(table1, table2).align();

    var data_diff = [];
    var table_diff = new daff.TableView(data_diff);

    var flags = new daff.CompareFlags();
    var highlighter = new daff.TableDiff(alignment,flags);
    highlighter.hilite(table_diff);

    var diff2html = new daff.DiffRender();
    diff2html.render(table_diff);
    var table_diff_html = diff2html.html();

    var $wrapper = $(
      '<div class="image-diff">' +
        '<div class="d2h-file-header">' +
          '<span class="d2h-file-name-wrapper">' +
            //'<span class="diff-expand-button"></span>' +
            '<span class="d2h-icon-wrapper">' +
              '<svg aria-hidden="true" class="d2h-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12">' +
                '<path d="M6 5H2v-1h4v1zM2 8h7v-1H2v1z m0 2h7v-1H2v1z m0 2h7v-1H2v1z m10-7.5v9.5c0 0.55-0.45 1-1 1H1c-0.55 0-1-0.45-1-1V2c0-0.55 0.45-1 1-1h7.5l3.5 3.5z m-1 0.5L8 2H1v12h10V5z">' +
                '</path>' +
                '</svg>' +
            '</span>' +
            '<span class="d2h-file-name"></span>' +
            '<span class="d2h-tag"></span>' +
          '</span>' +
        '</div>' +
        //'<div class="image-diff-controls"></div>' +
        '<div class="image-diff-container">' +
        '</div>' +
      '</div>'
    );

    $wrapper.find(".d2h-file-name").text(filename);

    $wrapper.find(".image-diff-container").html(table_diff_html);

    $wrapper.find("table").addClass("highlighter");

    // change append to remove previous elements.
    $(el).html($wrapper);
    /**el.find("table").addClass("highlighter");**/

    /* to apply styles of diffviewer */
    el.addClass("diffviewer");

    if (state.status === "same") {

      $wrapper.find(".d2h-tag")
        .addClass("d2h-changed d2h-changed-tag")
        .text("NOT CHANGED");

    } else if (state.status === "modified") {

      $wrapper.find(".d2h-tag")
        .addClass("d2h-changed d2h-changed-tag")
        .text("CHANGED");

    }

    return state;

  }

  var Views = (function() {
    var view_types = {};
    var view_order = [];

    // Add a new type of view, and keep track of order
    function add_view(view) {
      view_types[view.name] = view;
      view_order.push(view.name);
    }

    function summary() {
      return view_order.map(function(name) {
        return {
          name:  name,
          label: view_types[name].label
        };
      });
    }

    function create($container, $controls, old_img, new_img) {
      var views = {};
      var zoom_level = ZOOM_DEFAULT;
      var _dimensions = null;

      // Activate a particular view and hide others
      function activate(name) {
        if (!views[name]) {
          views[name] = view_types[name].create($container, $controls,
            old_img, new_img, zoom_level, dims);
        }

        for (var key in views) {
          if (!views.hasOwnProperty(key)) continue;

          if (key === name) {
            views[key].show();
          } else {
            views[key].hide();
          }
        }
      }

      // Set zoom level on all views
      function zoom(zoom) {
        zoom_level = zoom;
        for (var key in views) {
          if (!views.hasOwnProperty(key)) continue;

          views[key].zoom(zoom);
        }
      }

      // Get or set dimensions of old and new images.
      function dims(dimensions) {
        if (dimensions) {
          _dimensions = dimensions;
        }
        return _dimensions;
      }

      return {
        activate: activate,
        dims: dims,
        zoom: zoom
      };
    }

    return {
      add_view: add_view,
      summary: summary,
      create: create
    };
  })();

  Views.add_view((function() {
    var view = {
      name: "difference",
      label: "Difference"
    };

    view.create = function($container, $controls, old_img, new_img, zoom_level, dims) {
      var $wrapper = $(
        '<div class="image-difference"><img></img></div>'
      );
      $container.append($wrapper);

      var $img = $wrapper.find("img").on("dragstart", function() { return false; });

      resemble.outputSettings({
        useCrossOrigin: false,   // Needed for data URIs
        errorColor: {
          red: 200,
          green: 0,
          blue: 0
        },
        transparency: 0.2
      });

      // By default, resemble.js ignores some very small differences between
      // images. (https://github.com/r-lib/diffviewer/issues/9). Calling
      // ignoreNothing() tells it to show every difference.
      resemble(old_img).compareTo(new_img)
        .ignoreNothing()
        .onComplete(function(data) {
          if (!dims()) {
            // Store the dimensions if needed.
            dims({
              old: data.dims[0],
              new: data.dims[1]
            });
          }

          // Set zoom, if we haven't already successfully done so.
          zoom(zoom_level);
          $img.attr("src", data.getImageDataUrl());
        });

      function zoom(zoom_level) {
        if (!dims())
          return false;

        // Width of the output image - will be the same as the greater of the
        // widths of the two images.
        var natural_width = Math.max(dims().old.width, dims().new.width);
        $wrapper.css("width", natural_width * zoom_level + "px");
        return true;
      }

      // This call to zoom() will succeed if another view has already called
      // dims(); if this is the first view used, then it will do nothing.
      zoom(zoom_level);

      return {
        $el: $wrapper,
        show: function() { $wrapper.show(); },
        hide: function() { $wrapper.hide(); },
        zoom: zoom
      };
    };

    return view;
  })());

  Views.add_view((function() {
    var view = {
      name: "toggle",
      label: "Toggle"
    };

    view.create = function($container, $controls, old_img, new_img, zoom_level, dims) {
      var $wrapper = $(
        '<div class="image-toggle">' +
          '<div class="image-toggle-old"><img></img></div>' +
          '<div class="image-toggle-new"><img></img></div>' +
        '</div>'
      );
      $wrapper.find(".image-toggle-old > img")
        .attr("src", old_img)
        .on("dragstart", function () { return false; });
      $wrapper.find(".image-toggle-new > img")
        .attr("src", new_img)
        .on("dragstart", function () { return false; });

      // Add controls
      var $subcontrols = $(
        '<span>' +
          '<span class="image-diff-button image-diff-button-left image-toggle-button-old">Old</span>' +
          '<span class="image-diff-button image-diff-button-right image-toggle-button-new">New</span>' +
          '<span class="image-diff-button image-toggle-play-button"></span>' +
          '<span class="image-toggle-delay-slider">' +
            '<input type="range" min="0.25" max="2" value="1" step="0.25">' +
          '</span>' +
          '<span class="image-toggle-delay-text"></span>' +
        '</span>'
      );

      $controls.append($subcontrols);

      var $new_div = $wrapper.find(".image-toggle-new");
      var $old_div = $wrapper.find(".image-toggle-old");
      var $new_img = $new_div.find("img");
      var $old_img = $old_div.find("img");

      $container.append($wrapper);

      var $new_button = $controls.find(".image-toggle-button-new");
      var $old_button = $controls.find(".image-toggle-button-old");

      var new_visible = true;
      function toggle_new_visible() {
        if (new_visible) {
          hide_new();
        } else {
          show_new();
        }
      }

      function show_new() {
        $new_button.addClass("image-diff-button-selected");
        $old_button.removeClass("image-diff-button-selected");

        $new_div.show();
        new_visible = true;
      }

      function hide_new() {
        $old_button.addClass("image-diff-button-selected");
        $new_button.removeClass("image-diff-button-selected");

        $new_div.hide();
        new_visible = false;
      }


      $wrapper.on("mousedown", function(e) {
        if (e.which !== 1) return;
        clear_play_button();
        toggle_new_visible();
      });

      $new_button.on("mousedown", function(e) {
        if (e.which !== 1) return;
        clear_play_button();
        show_new();
      });

      $old_button.on("mousedown", function(e) {
        if (e.which !== 1) return;
        clear_play_button();
        hide_new();
      });


      var $play_button = $controls.find(".image-toggle-play-button");
      $play_button.on("mousedown", function(e) {
        // Make sure it's the left button
        if (e.which !== 1) return;

        if ($play_button.hasClass("image-toggle-play-button-pause")) {
          // If it's a pause symbol
          clear_play_button();
        } else {
          $play_button.addClass("image-toggle-play-button-pause");
          schedule_toggle();
        }
      });

      function clear_play_button() {
        $play_button.removeClass("image-toggle-play-button-pause");
        unschedule_toggle();
      }


      var $delay_slider = $controls.find('input[type="range"]');
      var delay;
      $delay_slider.on("input", function(e) {
        delay = parseFloat(this.value);
        $controls.find(".image-toggle-delay-text").text(delay + " s");
      });


      // Toggle visibility of new image, and schedule the same function to run
      // again after delay, if play button is selected.
      var toggle_timer;
      function schedule_toggle() {
        toggle_timer = setTimeout(function() {
          // If image diff has been removed from DOM, exit so we don't reschedule.
          if ($wrapper.closest(document.documentElement).length === 0)
            return;

          if ($play_button.hasClass("image-toggle-play-button-pause")) {
            toggle_new_visible();
            schedule_toggle();
          }
        }, delay * 1000);
      }
      function unschedule_toggle() {
        clearTimeout(toggle_timer);
      }

      // Start with Old visible
      hide_new();

      $delay_slider.trigger("input");
      $play_button.trigger({
        type: "mousedown",
        which: 1            // Simulate left button
      });


      var has_zoomed = false;

      function zoom(zoom_level) {
        var dim = dims();
        if (!dim)
          return false;

        if (has_zoomed) {
          $wrapper.addClass("zooming");

          // Get the duration of the transition, so that we can remove the
          // "zooming" class at the end of the transition. The zooming class
          // enables transitions, but we only want those transitions during
          // the zoom because they cause problems when dragging the slider.
          var duration = $wrapper.css('transition-duration');
          if (/^[0-9.]+s$/.test(duration)) {
            duration = parseFloat(duration);

            setTimeout(function() {
              $wrapper.removeClass("zooming");
            }, duration * 1000);
          }
        } else {
          // Don't use transitions for initial zoom.
          has_zoomed = true;
        }

        var max = {
          width:  Math.max(dim.old.width,  dim.new.width),
          height: Math.max(dim.old.height, dim.new.height)
        };

        $wrapper.css("width", zoom_level * max.width);

        $old_div
          .css("width",  zoom_level * max.width)
          .css("height", zoom_level * max.height);
        $new_div
          .css("width",  zoom_level * max.width)
          .css("height", zoom_level * max.height);
        $old_img
          .css("width",  zoom_level * dim.old.width)
          .css("height", zoom_level * dim.old.height);
        $new_img
          .css("width",  zoom_level * dim.new.width)
          .css("height", zoom_level * dim.new.height);

        return true;
      }

      // Try to zoom immediately; if not successful, that means we have to
      // wait for the images to be loaded and then we can get the dimensions.
      if (!zoom(zoom_level)) {
        var imgs_loaded = 0;
        var img_loaded_callback = function() {
          imgs_loaded++;
          // Set zooming after both images loaded
          if (imgs_loaded == 2) {
            dims({
              old: {
                width:  $old_img.prop("naturalWidth"),
                height: $old_img.prop("naturalHeight")
              },
              new: {
                width:  $new_img.prop("naturalWidth"),
                height: $new_img.prop("naturalHeight")
              }
            });

            zoom(zoom_level);
          }
        };

        $old_img.one("load", img_loaded_callback);
        $new_img.one("load", img_loaded_callback);
      }

      // State of play button when hidden. Need to know this so that when we
      // show it again, we have the same state.
      var prev_play_state = false;

      return {
        $el: $wrapper,

        show: function() {
          if (prev_play_state) {
            schedule_toggle();
          }
          $wrapper.show();
          $subcontrols.show();
        },

        hide: function() {
          prev_play_state = $play_button.hasClass("image-toggle-play-button-pause");
          if (prev_play_state) {
            unschedule_toggle();
          }
          $wrapper.hide();
          $subcontrols.hide();
        },
        zoom: zoom
      };
    };

    return view;
  })());

  Views.add_view((function() {
    var view = {
      name: "slider",
      label: "Slider"
    };

    view.create = function($container, $controls, old_img, new_img, zoom_level, dims) {
      var $wrapper = $(
        '<div class="image-slider">' +
          '<div class="image-slider-right">' +
            '<img></img>' +
            '<div class="image-slider-label">' +
              '<div class="image-slider-label-text">New</div>' +
            '</div>' +
          '</div>' +
          '<div class="image-slider-left">' +
            '<img></img>' +
            '<div class="image-slider-label">' +
              '<div class="image-slider-label-text">Old</div>' +
            '</div>' +
          '</div>' +
        '</div>'
      );
      $wrapper.find(".image-slider-left > img")
        .attr("src", old_img)
        .on("dragstart", function () { return false; });
      $wrapper.find(".image-slider-right > img")
        .attr("src", new_img)
        .on("dragstart", function () { return false; });

      var $old_div = $wrapper.find(".image-slider-left");
      var $new_div = $wrapper.find(".image-slider-right");
      var $old_img = $old_div.find("img");
      var $new_img = $new_div.find("img");

      $container.append($wrapper);

      var $old_label = $old_div.find(".image-slider-label");
      var $new_label = $new_div.find(".image-slider-label");

      // Add mouse event listener
      $wrapper.on("mousedown", function(e) {
        // Make sure it's the left button
        if (e.which !== 1) return;

        slide_to(e.pageX);

        $(window).on("mousemove.image-slider", function(e) {
          slide_to(e.pageX);
        });

        // Need to bind to window to detect mouseup events outside of browser
         // window.
        $(window).one("mouseup", function(e) {
          // Make sure it's the left button
          if (e.which !== 1) return;

          $(window).off("mousemove.image-slider");
        });
      });

      function min_x() {
        return $new_div.offset().left;
      }
      function max_x() {
        // Attempt to get the pixel width from style attribute
        var old_width = get_target_width($old_div);
        var new_width = get_target_width($new_div);

        return min_x() + Math.max(old_width, new_width);
      }

      // This attempts to get the pixel width from a style attribute, and if
      // that fails, gets the computed width (by calling width()). The reason
      // that we want to try to get the width from the style is because,
      // during a transition, this gives us the _target_ width, whereas the
      // computed width gives us the width at the moment the function is
      // called. In many cases, we need to get the target width.
      function get_target_width($el) {
        var width = $el[0].style.width;
        if (/^[0-9.]+px$/.test(width)) {
          // Subtract border width because we want to return the inner width.
          return parseFloat(width) -
                 parseFloat($el.css("border-left-width")) -
                 parseFloat($el.css("border-right-width"));
        } else {
          return $old_div.width();
        }
      }

      function slide_to(x) {
        // Constrain mouse position to within image div
        x = Math.max(x, min_x());
        x = Math.min(x, max_x());

        // Change width of div
        $old_div.width(x - $old_div.offset().left);

        set_label_visibility();
      }

      // Make labels disappear/reappear depending on how close slider is.
      function set_label_visibility() {
        var x = $old_div.offset().left + get_target_width($old_div);

        // Use css visibility instead of show()/hide() because the latter will
        // make offset() return 0.
        if (x < $old_label.offset().left + $old_label.width() + 50) {
          $old_label.css("visibility", "hidden");
        } else {
          $old_label.css("visibility", "visible");
        }

        // Can't use $new_label.offset().left because during transitions, it
        // gives the current value instead of target value. We need to compute
        // the target left position.
        var new_label_left = $new_div.offset().left + get_target_width($new_div) -
                             $new_label.width();
        if (x > new_label_left - 50) {
          $new_label.css("visibility", "hidden");
        } else {
          $new_label.css("visibility", "visible");
        }
      }

      function slide_to_proportion(p, min, max) {
        $old_div.width((max_x() - min_x()) * p);
      }

      function get_slide_proportion() {
        var x = $old_div.offset().left + get_target_width($old_div);
        return (x - min_x()) / (max_x() - min_x());
      }

      var has_zoomed = false;

      function zoom(zoom_level) {
        var dim = dims();
        if (!dim)
          return false;

        var proportion;
        if (has_zoomed) {
          proportion = get_slide_proportion();
          $wrapper.addClass("zooming");

          // Get the duration of the transition, so that we can remove the
          // "zooming" class at the end of the transition. The zooming class
          // enables transitions, but we only want those transitions during
          // the zoom because they cause problems when dragging the slider.
          var duration = $wrapper.css('transition-duration');
          // In most browsers (Chrome, Firefox, Safari) the string is "0.15s",
          // but in RStudio on Mac, it is "0.15s, 0.15s", so we need the
          // regexp to be a little lenient.
          if (/^[0-9.]+s/.test(duration)) {
            duration = parseFloat(duration);

            setTimeout(function() {
              $wrapper.removeClass("zooming");
            }, duration * 1000);
          }
        } else {
          // On first call to zoom(), start in the middle, and don't use transitions.
          proportion = 0.5;
          has_zoomed = true;
        }

        var max = {
          width:  Math.max(dim.old.width,  dim.new.width),
          height: Math.max(dim.old.height, dim.new.height)
        };

        $wrapper.css("width", zoom_level * max.width);

        $old_div
          .css("width",  zoom_level * max.width)
          .css("height", zoom_level * max.height);
        $new_div
          .css("width",  zoom_level * max.width)
          .css("height", zoom_level * max.height);
        $old_img
          .css("height", zoom_level * dim.old.height);
        $new_img
          .css("width",  zoom_level * dim.new.width)
          .css("height", zoom_level * dim.new.height);

        slide_to_proportion(proportion); // Sets the width for $old_img
        set_label_visibility();

        return true;
      }

      // Try to zoom immediately; if not successful, that means we have to
      // wait for the images to be loaded and then we can get the dimensions.
      if (!zoom(zoom_level)) {
        var imgs_loaded = 0;
        var img_loaded_callback = function() {
          imgs_loaded++;
          // Set zooming after both images loaded
          if (imgs_loaded == 2) {
            dims({
              old: {
                width:  $old_img.prop("naturalWidth"),
                height: $old_img.prop("naturalHeight")
              },
              new: {
                width:  $new_img.prop("naturalWidth"),
                height: $new_img.prop("naturalHeight")
              }
            });

            zoom(zoom_level);
          }
        };

        $old_img.one("load", img_loaded_callback);
        $new_img.one("load", img_loaded_callback);
      }


      return {
        $el: $wrapper,
        show: function() { $wrapper.show(); },
        hide: function() { $wrapper.hide(); },
        zoom: zoom
      };
    };

    return view;
  })());

  function generate_view_buttons(view_summary) {
    var str = "";
    var position;
    for (var i=0; i<view_summary.length; i++) {
      var item = view_summary[i];

      if      (i === 0)                     position = "left";
      else if (i === view_summary.length-1) position = "right";
      else                                 position = "middle";

      str += '<span class="image-diff-button image-diff-button-' + position +
        '" data-button="' + item.name + '">' + item.label + '</span>';
    }

    return str;
  }

  function enable_expand_buttons(el) {
    $(el).on("mousedown", ".diff-expand-button", function(e) {
      if (e.which !== 1) return;

      var $button = $(this);

      // Search for closest text diff or image diff wrapper.
      var $wrapper = $button.closest(".d2h-file-wrapper,.image-diff");

      if ($wrapper.hasClass("diffviewer-collapsed")) {
        $wrapper.removeClass("diffviewer-collapsed");
      } else {
        $wrapper.addClass("diffviewer-collapsed");
      }
    });
  }

  function render_file_change_table(el, id, files) {
    var $el = $(el);

    var $list = $('<ul class="diff-file-list"></ul>');
    files.map(function(file, idx) {
      $list.append(
        '<li class="diff-file-' + file.status + '">' +
          '<span class="diff-file-icon"></span>' +
          '<a href = "#' + id + "-file" + idx + '">' +
            file.filename +
          '</a>' +
        '</li>'
      );
    });

    $el.prepend($list);
  }

  return diffviewer;
}());
