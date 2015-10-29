$(function() {
  var tabs = $('body.rails_admin .has_many_association_type .nav-tabs');

  tabs.sortable({
    cursor: 'move',
    stop: function (event, ui) {
      var navTabs = $(ui.item).parent();
      $(navTabs).find('.ui-sortable-handle').each(function(i) {
        var tabContent = $($(this).find('a').attr('href'));
        tabContent.find('input[name$="[position]"]').attr('value', i + 1);
      });
    }
  });
});
