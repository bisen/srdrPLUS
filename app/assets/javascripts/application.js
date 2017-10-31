// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require toastr_rails
//= require select2
//= require cocoon
//= require jquery_mark_es6
//= require react
//= require react_ujs
//= require components
//= require_tree .

//$(function(){ $(document).foundation(); });

'use strict';

// Set toastr.js options
toastr.options = {
  'closeButton': false,
  'showMethod': 'slideDown',
  'hideMethod': 'slideUp',
  'closeMethod': 'slideUp',
  'positionClass': 'toast-bottom-right',
  'closeDuration': 200
};

document.addEventListener( 'turbolinks:load', function() {
  $( document ).foundation();

//  $( '#options' )
//    .on('cocoon:before-insert', function(e,task_to_be_added) {
//      task_to_be_added.fadeIn('slow');
//    })
//    .on('cocoon:after-insert', function(e, added_task) {
//      // e.g. set the background of inserted task
//      added_task.css("background","red");
//    })
//    .on('cocoon:before-remove', function(e, task) {
//      // allow some time for the animation to complete
//      $(this).data('remove-timeout', 1000);
//      task.fadeOut('slow');
//    });

} );
