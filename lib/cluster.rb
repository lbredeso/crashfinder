# Adapted from:  http://www.appelsiini.net/2008/11/introduction-to-marker-clustering-with-google-maps
class Cluster
  OFFSET = 268435456
  RADIUS = 85445659.4471
  
  # If the list of events is large, ensure it is sorted by longitude for reasonable performance.
  def create year, events, distance, zoom
    puts "Removing clusters for year: #{year}, zoom: #{zoom}"
    CrashCluster.collection.remove(year: year, zoom: zoom)
    
    beginning_time = Time.now
    puts "Building cluster for year: #{year}, zoom: #{zoom}..."
    
    clusters = []
    events = events.clone
    puts "Searching through #{events.size} events..."
    
    # Loop until all events are compared
    until events.size == 0
      last_event = events.shift
      cluster = []
      
      for event in events
        pixels = pixel_distance last_event.lat, last_event.lng, event.lat, event.lng, zoom
        
        # If two markers are closer than given distance add the target marker to the cluster.
        if pixels < distance
          cluster.push event
        end
        
        # Break out early if there's no chance further events will be in this cluster
        lng_distance = pixel_distance last_event.lat, last_event.lng, last_event.lat, event.lng, zoom
        if lng_distance >= distance
          break
        end
      end
      
      # If a marker has been added to cluster, add also the one
      # we were comparing to and remove the original from array.
      if cluster.size > 0
        cluster.push last_event
        clusters.push cluster
        events -= cluster
      else
        clusters.push [last_event]
      end
    end
    
    # Persist the new clusters
    clusters.each do |cluster|
      crash_cluster = CrashCluster.new year: year, count: cluster.size, zoom: zoom
      crash_cluster.lng = cluster.map { |c| c.lng }.inject(0) { |sum, lng| sum + lng } / cluster.size
      crash_cluster.lat = cluster.map { |c| c.lat }.inject(0) { |sum, lat| sum + lat } / cluster.size
      crash_cluster.save
    end
    end_time = Time.now
    puts "Year: #{year}, zoom: #{zoom} cluster building took #{end_time - beginning_time} seconds"
  end
  
  def lng_to_x lon
    (OFFSET + RADIUS * lon * Math::PI / 180).round
  end
  
  def lat_to_y lat
    (OFFSET - RADIUS * Math.log((1 + Math.sin(lat * Math::PI / 180)) / (1 - Math.sin(lat * Math::PI / 180))) / 2).round
  end
  
  def pixel_distance lat1, lon1, lat2, lon2, zoom
    x1, y1 = lng_to_x(lon1), lat_to_y(lat1)
    x2, y2 = lng_to_x(lon2), lat_to_y(lat2)
    
    Math.sqrt(((x1 - x2) ** 2) + ((y1 - y2) ** 2)).ceil >> (21 - zoom)
  end
end