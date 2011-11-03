// Put your application scripts here

jQuery(function($) {
  $("form[data-remote=true]").ajaxStart(function() {
    $('#error').html("");
    $("#ajax-loader").show();
  });

  $("form[data-remote=true]").ajaxError(function(e, xhr, settings, exception) {
    $('#error').html("Server Error - " + xhr.status);
  });

  $("form[data-remote=true]").ajaxStop(function() {
    $("#ajax-loader").hide();
  });
});
