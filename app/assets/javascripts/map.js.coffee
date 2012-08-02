jQuery ->
  mapOptions = {
    ### 
    # The center is in St. Paul at the moment.
    ###
    center: new google.maps.LatLng(45.954215, -93.089819),
    zoom: 5,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  @map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  drawingManager = new google.maps.drawing.DrawingManager({
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_LEFT,
      drawingModes: [google.maps.drawing.OverlayType.RECTANGLE]
    },
    map: @map
  })
  
  @markers = []
  @infoWindow
  @infoWindowMarker
  clearMarkers = =>
    $.each(@markers, (index, marker) =>
      marker.setMap(null) if (marker != @infoWindowMarker)
    )
    @markers = []
  
  processCrashes = (args) =>
    sw = args.southWest || @map.getBounds().getSouthWest()
    ne = args.northEast || @map.getBounds().getNorthEast()
  
    $.ajax({
      url: args.path + "?year=" + args.year + "&zoom=" + args.zoom +
        "&sw_lat=" + sw.lat() + "&sw_lon=" + sw.lng() + "&ne_lat=" + ne.lat() + "&ne_lon=" + ne.lng(),
      dataType: 'json',
      success: (response) =>
        clearMarkers()
        
        if args.callback
          args.callback response
        else
          $.each(response, (index, crashData) =>
            crash = new google.maps.Marker({
              position: new google.maps.LatLng(crashData.location[1], crashData.location[0]),
              map: @map,
              icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + crashData.count + "|FF0000|FFFFFF"
            })
            @markers.push crash
            
            google.maps.event.addListener(crash, 'click', =>
              @infoWindow?.close()
              @infoWindowMarker = crash
              @infoWindow = new google.maps.InfoWindow({
                content: args.content(crashData),
                size: new google.maps.Size(50, 50)
              })
              @infoWindow.open @map, crash
            )
          )
    })
  
  google.maps.event.addListener(drawingManager, 'rectanglecomplete', (rectangle) =>
    southWest = rectangle.getBounds().getSouthWest()
    northEast = rectangle.getBounds().getNorthEast()
    processCrashes({
      path: '/crashes',
      year: '2011', 
      southWest: southWest,
      northEast: northEast,
      callback: (response) =>
        crash = new google.maps.Marker({
          position: new google.maps.LatLng((southWest.lat() + northEast.lat()) / 2, (southWest.lng() + northEast.lng()) / 2),
          map: @map,
          icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + response.count + "|FF0000|000000"
        })
        @markers.push crash
        
        @infoWindow?.close()
        @infoWindowMarker = crash
        @infoWindow = new google.maps.InfoWindow({
          content: "<p>" + '2011' + "</p><p>" + response.length + " crashes</p>",
          size: new google.maps.Size(50, 50)
        })
        @infoWindow.open @map, crash
    })
  )
  
  google.maps.event.addListener(@map, 'idle', =>
    zoom = @map.getZoom()
    processCrashes({
      path: '/crashes/clusters',
      year: '2011',
      zoom: zoom,
      content: (crashData) ->
        "<p>" + crashData.year + "</p><p>" + crashData.count + "</p>"
    })
  )
