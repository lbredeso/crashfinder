var LocationMap = function() {
  var locations = {};
  
  var put = function(location, rectangle) {
    locations[location.id] = {
      location: location,
      rectangle: rectangle
    };
    return locations;
  };
  
  var remove = function(locationId) {
    delete locations[locationId];
    return locations;
  }
  
  var get = function(locationId) {
    return locations[locationId];
  };
  
  var first = function() {
    if (Object.keys(locations).length > 0) {
      return locations[Object.keys(locations)[0]];
    } else {
      return null;
    }
  };
  
  // Google Maps Drawing API
  var map = new google.maps.Map(document.getElementById("map_canvas"));
  
  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_LEFT,
      drawingModes: [google.maps.drawing.OverlayType.RECTANGLE]
    },
    map: map
  });
  
  google.maps.event.addListener(drawingManager, 'rectanglecomplete', function(rectangle) {
    saveLocation(rectangle, 'POST');
  });
  
  // Location API
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
      if (map.getZoom() < 15) {
        alert("Please zoom in at least " + (15 - map.getZoom()) + " more time(s) to create a location.");
        rectangle.setMap(null);
        return;
      }
      location['label'] = prompt("What do you want to call this location?");
      if (!location['label']) {
        rectangle.setMap(null);
        return;
      }
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
        var location = response;
        put(location, rectangle);
        spinner.stop();
        $('#spinner').hide();
        rectangle.setOptions({
          editable: true
        });
        if (method == 'POST') {
          $('#location').append('<option value="' + location.id + '">' + location.label + '</option>');
          center(location.id);
        }
      }
    });
  };
  
  var blank = function() {
    map.setOptions({
      // The center is in St. Paul at the moment.
      center: new google.maps.LatLng(45.954215, -93.089819),
      zoom: 5,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
  };
  
  var center = function(locationId) {
    var doCenter = function(location) {
      map.setOptions({
        center: new google.maps.LatLng(location.center_lat, location.center_lng),
        zoom: location.zoom || 16,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
        
      $('#delete').data('locationId', location.id);
    }
    
    if (get(locationId)) {
      doCenter(get(locationId).location);
    } else {
      $.ajax({
        url: "/locations/" + locationId,
        dataType: 'json',
        success: function(response) {
          var location = response;
          doCenter(location);
        }
      });
    }
  };
  
  var draw = function(locationId) {
    var rectangle = new google.maps.Rectangle();
    $.ajax({
      url: "/locations/" + locationId,
      dataType: 'json',
      success: function(response) {
        var location = response;
            
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
        
        put(location, rectangle);
      }
    });
    return rectangle;
  };
  
  var erase = function(locationId) {
    $.ajax({
      url: "/locations" + (locationId ? "/" + locationId : ""),
      dataType: 'json',
      type: 'DELETE',
      success: function(response) {
        get(locationId).rectangle.setMap(null);
        remove(locationId);
        if (first()) {
          center(first().location.id);
        } else {
          // We could technically revert to the original location-less display, but the user already knows how to use locations by this point...
        }
        $("#location option[value='" + locationId + "']").remove();
      }
    });
  };
  
  return {
    blank: function() {
      blank();
    },
    
    center: function(locationId) {
      center(locationId);
    },
    
    draw: function(locationId) {
      return draw(locationId);
    },
    
    erase: function(locationId) {
      var doIt = confirm("Are you sure you want to delete this location?");
      if (doIt) {
        erase(locationId);
      }
    }
  };
};