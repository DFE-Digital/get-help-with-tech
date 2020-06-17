hideOnLoad = function() {
  $('.non-js-only').hide();
  $('.js-only').show();
}

setupSelectAllNone = function() {
  $('#all-rows').change(function() {
    console.log('change!')
    console.log($(this))
    className = $(this).parent().data('controls')
    controlled_items = $(this).closest('table').find('.' + className).find('input[type=checkbox]')
    controlled_items.prop('checked', $(this).prop('checked'))
  })
}

$(document).ready(function() {
  hideOnLoad();
  setupSelectAllNone();
});
