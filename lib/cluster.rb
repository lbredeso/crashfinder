# Adapted from:  http://www.appelsiini.net/2008/11/introduction-to-marker-clustering-with-google-maps
class Cluster
  OFFSET = 268435456
  RADIUS = 85445659.4471
  
  def find_by events, singles, distance, zoom
    clustered = []
    events = events.clone - singles
    puts "Searching through #{events.size} events..."
    
    # Loop until all events are compared
    # Optimizing this is complicated.  Ordering won't really help, as the search is in 2 dimensions.
    # Keeping track of "single" cluster events may be helpful.
    until events.size == 0
      start_matching = false
      last_event = events.pop
      cluster = []
      
      events.each do |event|
        pixels = pixel_distance last_event.lat, last_event.lng, event.lat, event.lng, zoom
        
        # If two markers are closer than given distance remove
        # target marker from array and add it to cluster.
        if pixels < distance
          cluster.push event
        end
      end
      
      # If a marker has been added to cluster, add also the one
      # we were comparing to and remove the original from array.
      if cluster.size > 0
        cluster.push last_event
        clustered.push cluster
        events -= cluster
      else
        singles.push last_event
      end
    end
    
    { data: clustered, singles: singles }
  end
  
  def lon_to_x lon
    (OFFSET + RADIUS * lon * Math::PI / 180).round
  end
  
  def lat_to_y lat
    (OFFSET - RADIUS * Math.log((1 + Math.sin(lat * Math::PI / 180)) / (1 - Math.sin(lat * Math::PI / 180))) / 2).round
  end
  
  def pixel_distance lat1, lon1, lat2, lon2, zoom
    x1, y1 = lon_to_x(lon1), lat_to_y(lat1)
    x2, y2 = lon_to_x(lon2), lat_to_y(lat2)
    
    Math.sqrt(((x1 - x2) ** 2) + ((y1 - y2) ** 2)).ceil >> (21 - zoom)
  end
end