var LocationMap = function() {
  var map = new google.maps.Map(document.getElementById("map_canvas"));
  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_LEFT,
      drawingModes: [google.maps.drawing.OverlayType.RECTANGLE]
    },
    map: map
  });
  
  var saveLocation = function(rectangle, method, locationId) {
    var location = {
      id: locationId,
      zoom: map.getZoom(),
      sw_lat: rectangle.getBounds().getSouthWest().lat(),
      sw_lng: rectangle.getBounds().getSouthWest().lng(),
      ne_lat: rectangle.getBounds().getNorthEast().lat(),
      ne_lng: rectangle.getBounds().getNorthEast().lng()
    };
    if (method == 'POST') {
      location['label'] = prompt("What do you want to call this location?");
    }
    var opts = {
      lines: 12, // The number of lines to draw
		  length: 7, // The length of each line
		  width: 5, // The line thickness
		  radius: 10, // The radius of the inner circle
		  color: '#fff', // #rbg or #rrggbb
		  speed: 1, // Rounds per second
		  trail: 66, // Afterglow percentage
		  shadow: true // Whether to render a shadow
    };
    var spinner = new Spinner(opts).spin();
    $('#spinner').show().append(spinner.el);
    
    $.ajax({
      url: "/locations" + (locationId ? "/" + locationId : ""),
      dataType: 'json',
      type: method,
      data: {
        location: location
      },
      success: function(response) {
        spinner.stop();
        $('#spinner').hide();
        var location = response;
        rectangle.setOptions({
          editable: true
        });
        if (method == 'POST') {
          $('#location').append('<option value="' + location.id + '">' + location.label + '</option>');
        }
      }
    });
  };
  
  google.maps.event.addListener(drawingManager, 'rectanglecomplete', function(rectangle) {
    saveLocation(rectangle, 'POST');
  });
  
  return {
    blank: function() {
      map.setOptions({
        // The center is in St. Paul at the moment.
        center: new google.maps.LatLng(45.954215, -93.089819),
        zoom: 5,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
    },
    
    center: function(locationId) {
      $.ajax({
        url: "/locations/" + locationId,
        dataType: 'json',
        success: function(response) {
          var location = response;
            
          map.setOptions({
            center: new google.maps.LatLng(location.center_lat, location.center_lng),
            zoom: location.zoom || 16,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          });
        }
      });
    },
    
    draw: function(locationId) {
      $.ajax({
        url: "/locations/" + locationId,
        dataType: 'json',
        success: function(response) {
          var location = response;
            
          var rectangle = new google.maps.Rectangle();
          rectangle.setOptions({
            editable: true,
            map: map,
            center: new google.maps.LatLng(location.center_lat, location.center_lng),
            bounds: new google.maps.LatLngBounds(
              new google.maps.LatLng(location.sw_lat, location.sw_lng),
              new google.maps.LatLng(location.ne_lat, location.ne_lng)
            )
          });
            
          google.maps.event.addListener(rectangle, 'bounds_changed', function() {
            saveLocation(rectangle, 'PUT', locationId);
          });
        }
      });
    }
  };
};