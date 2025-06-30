jQuery(function($) {
  $(".craft-calculator form[data-remote=true]")
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

  $(".craft-calculator select").change(function() {
    $(this).closest("form").submit();
  });
});
