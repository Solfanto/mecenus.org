// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require rails-timeago-all

Turbolinks.enableProgressBar();
Turbolinks.enableTransitionCache();

$( document ).ready(function() {
  $('.js-tab a').on("click", function (e) {
    e.preventDefault();
    $(this).tab('show');
  })

  $("#stripe").on("ajax:send", function(xhr) {
    $("#stripe > .content input").attr('disabled','disabled');
  }).on("ajax:success", function(e, xhr, status, error) {
    $("#stripe > .content").hide();
    $("#stripe > .success-content").show();
    $(".confirm-btn").removeAttr('disabled');
  }).on("ajax:error", function(e, xhr, status, error) {
    $("#stripe > .content input").removeAttr('disabled');
    alert($.parseJSON(xhr.responseText).error.message);
  });

  $('.follow-button, .unfollow-button').on('ajax:success', function(e, data, status, xhr) {
    id = $(this).data('id');

    if (data.success && data.action == 'follow') {
      $(".follow-button[data-id=" + id + "]").hide();
      $(".unfollow-button[data-id=" + id + "]").show();
    }
    else if (data.success && data.action == 'unfollow') {
      $(".unfollow-button[data-id=" + id + "]").hide();
      $(".follow-button[data-id=" + id + "]").show();
    }
  });
});