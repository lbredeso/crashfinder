var ClusterMap = function() {
  return {
    draw: function() {
      var currentYear = 2011;
      var currentZoom = 5;
  
      var mapOptions = {
        // The center is in St. Paul at the moment.
        center: new google.maps.LatLng(45.954215, -93.089819),
        zoom: currentZoom,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  
      var markers = [];
      var infoWindow;
      var infoWindowMarker;

      var clearMarkers = function(zoom) {
        $.each(markers, function(index, marker) {
          if (marker != infoWindowMarker || currentZoom != zoom) {
            marker.setMap(null);
          }
        });
        markers = [];
      };
  
      var findMaxCrashCount = function(crashes) {
        var max = 0;
        $.each(crashes, function(index, crash) {
          if (crash.count > max) {
            max = crash.count;
          }
        })
        return max;
      };
  
      var processCrashes = function(args) {
        var sw = args.southWest || map.getBounds().getSouthWest();
        var ne = args.northEast || map.getBounds().getNorthEast();
  
        $.ajax({
          url: args.path + "?year=" + args.year + "&zoom=" + args.zoom +
            "&sw_lat=" + sw.lat() + "&sw_lng=" + sw.lng() + "&ne_lat=" + ne.lat() + "&ne_lng=" + ne.lng(),
          dataType: 'json',
          success: function(response) {
            clearMarkers(args.zoom);
            currentZoom = args.zoom;
        
            if (args.callback) {
              args.callback(response);
            } else {
              var maxCrashCount = findMaxCrashCount(response);
              var color = Color.generate(maxCrashCount);
              $.each(response, function(index, crashData) {
                var crash = new google.maps.Marker({
                  position: new google.maps.LatLng(crashData.lat, crashData.lng),
                  map: map,
                  icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=|" + color.toHex(crashData.count) + "|FFFFFF"
                });
                markers.push(crash);
            
                google.maps.event.addListener(crash, 'click', function() {
                  if (infoWindow) {
                    infoWindow.close();
                  }
                  infoWindowMarker = crash;
                  infoWindow = new google.maps.InfoWindow({
                    content: args.content(crashData),
                    size: new google.maps.Size(50, 50)
                  });
                  infoWindow.open(map, crash);
                });
              });
            }
          }
        });
      };
  
      google.maps.event.addListener(map, 'idle', function() {
        zoom = map.getZoom();
    
        // Keep the zoom within the bounds we have data for.
        zoom = zoom < 5 ? 5 : zoom;
        zoom = zoom > 16 ? 16 : zoom;
    
        processCrashes({
          path: '/clusters',
          year: currentYear,
          zoom: zoom,
          content: function(crashData) {
            return "<p>" + crashData.count + " crashes</p>";
          }
        });
      });
    }
  };
};
