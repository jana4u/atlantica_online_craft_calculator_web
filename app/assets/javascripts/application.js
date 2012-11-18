// Put your application scripts here

jQuery(function($) {
  $("form[data-remote=true]")
  .bind("ajax:before", function() {
    $('#error').html("");
    $("#ajax-loader").show();
  })

  .bind("ajax:failure", function(event, xhr, status, error) {
    $('#error').html("Server Error - " + xhr.status);
  })

  .bind("ajax:complete", function() {
    $("#ajax-loader").hide();
  });

  $("select").change(function() {
    $(this).closest("form").submit();
  });
});
