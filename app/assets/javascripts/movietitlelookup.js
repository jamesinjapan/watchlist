$(document).ready( function() {
  $(function() {
    $( '#movie-title-lookup' ).autocomplete({
      source: function(request, response){
          remoteResults = $.ajax({
          url: movietitlelookup_path,
          dataType: "json",
          data: { t: request.term },
          success: function( data ) {
            response( $.map( data, function( item ) {
              return { 
                label: item.label,
                value: item.value,
              };   
            }));
          }
        });
        
      },
      minLength: 3,
      focus: function(event, ui) {
        $(this).val(ui.item.label);
        return false;
      },
      select: function(event, ui) {
        $('#movie-id-hidden').val(ui.item.value);
        $(this).val(ui.item.label);
        $("#movie-lookup-form").submit();
        return false;
      },
      _resizeMenu: function () {
        var ul = this.menu.element;
        ul.outerWidth(this.element.outerWidth());
      }
    });
  });
});