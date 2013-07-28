var TopMap = function() {
  return {
    draw: function() {
      var currentYear = 2012;
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
  
      var findMaxCrashCount = function(crashes) {
        var max = 0;
        $.each(crashes, function(index, crash) {
          if (crash.count > max) {
            max = crash.count;
          }
        })
        return max;
      };
  
      $.ajax({
        url: "/top",
        dataType: 'json',
        success: function(response) {
          var maxCrashCount = findMaxCrashCount(response);
          var color = Color.generate(maxCrashCount);
          $.each(response, function(index, crashData) {
            var crash = new google.maps.Marker({
              position: new google.maps.LatLng(crashData.lat, crashData.lng),
              map: map,
              icon: "https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=" + (index + 1) + "|" + color.toHex(crashData.count) + "|FFFFFF"
            });
            markers.push(crash);
            
            google.maps.event.addListener(crash, 'click', function() {
              if (infoWindow) {
                infoWindow.close();
              }
              infoWindowMarker = crash;
              infoWindow = new google.maps.InfoWindow({
                content: "<p>" + crashData.count + " crashes</p>",
                size: new google.maps.Size(50, 50)
              });
              infoWindow.open(map, crash);
            });
          });
        }
      });
    }
  };
};
