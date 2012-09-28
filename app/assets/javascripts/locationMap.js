var LocationMap = function() {
  var map = new google.maps.Map(document.getElementById("map_canvas"));
  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_LEFT,
      drawingModes: [google.maps.drawing.OverlayType.RECTANGLE]
    },
    map: map
  });
  
  return {
    draw: function(locationId) {
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
            $.ajax({
              url: "/locations/" + locationId,
              dataType: 'json',
              type: 'PUT',
              data: {
                location: {
                  id: locationId,
                  zoom: map.getZoom(),
                  sw_lat: rectangle.getBounds().getSouthWest().lat(),
                  sw_lng: rectangle.getBounds().getSouthWest().lng(),
                  ne_lat: rectangle.getBounds().getNorthEast().lat(),
                  ne_lng: rectangle.getBounds().getNorthEast().lng()
                }
              },
              success: function(response) {
                alert("Success!")
              }
            });
          });
        }
      });
  
      google.maps.event.addListener(drawingManager, 'rectanglecomplete', function(rectangle) {
        var southWest = rectangle.getBounds().getSouthWest();
        var northEast = rectangle.getBounds().getNorthEast();
        processCrashes({
          path: '/locations/' + locationId,
          southWest: southWest,
          northEast: northEast,
          callback: function(response) {
            crash = new google.maps.Marker({
              position: new google.maps.LatLng((southWest.lat() + northEast.lat()) / 2, (southWest.lng() + northEast.lng()) / 2),
              map: map,
              icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + response.count + "|FF0000|000000"
            });
            markers.push(crash);
        
            if (infoWindow) {
              infoWindow.close();
            }
            infoWindowMarker = crash;
            infoWindow = new google.maps.InfoWindow({
              content: "<p>" + response.length + " crashes</p>",
              size: new google.maps.Size(50, 50)
            });
            infoWindow.open(map, crash);
          }
        });
      });
      
    }
  };
};