var TrendMap = function() {
  return {
    draw: function() {
      var currentZoom = 5;
  
      var mapOptions = {
        // The center is in St. Paul at the moment.
        center: new google.maps.LatLng(45.954215, -93.089819),
        zoom: currentZoom,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
      var drawingManager = new google.maps.drawing.DrawingManager({
        drawingControlOptions: {
          position: google.maps.ControlPosition.TOP_LEFT,
          drawingModes: [google.maps.drawing.OverlayType.RECTANGLE]
        },
        map: map
      });
  
      google.maps.event.addListener(drawingManager, 'rectanglecomplete', function(rectangle) {
        var southWest = rectangle.getBounds().getSouthWest();
        var northEast = rectangle.getBounds().getNorthEast();
        processCrashes({
          path: '/crashes',
          year: currentYear,
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