require 'cluster'

class CrashCluster
  include MongoMapper::Document
  
  key :lng, Float
  key :lat, Float
  key :count, Integer
  key :year, String
  key :zoom, Integer
  
  BATCH_SIZE = 10000
  
  def self.build year, zoom_levels
    puts "Fetching located crashes that occurred in #{year}..."
    
    # Due to MongoDB's "too much data for sort() with no index. add an index or specify a smaller limit" error,
    # we must unfortunately do our sort in Ruby.
    crashes = Crash.all({
      :year => year,
      :location => { '$exists' => true }
    }).sort { |a, b| a.location <=> b.location }
    
    zoom_levels.each do |zoom|
      puts "Removing clusters for year: #{year}, zoom: #{zoom}"
      CrashCluster.collection.remove(year: year, zoom: zoom)
      
      beginning_time = Time.now
      puts "Building cluster for year: #{year}, zoom: #{zoom}..."
      clusters = Cluster.new.find_by crashes, 20, zoom
      clusters.each do |cluster|
        crash_cluster = CrashCluster.new year: year, count: cluster.size, zoom: zoom
        crash_cluster.lng = cluster.map { |c| c.location[0] }.inject(0) { |sum, longitude| sum + longitude } / cluster.size
        crash_cluster.lat = cluster.map { |c| c.location[1] }.inject(0) { |sum, latitude| sum + latitude } / cluster.size
        crash_cluster.save
      end
      end_time = Time.now
      puts "Year: #{year}, zoom: #{zoom} cluster building took #{end_time - beginning_time} seconds"
    end
  end
  
  def as_json options = {}
    {
      year: self.year,
      count: self.count,
      lng: self.lng,
      lat: self.lat
    }
  end
end