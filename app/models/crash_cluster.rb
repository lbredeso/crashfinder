require 'cluster'

class CrashCluster
  include MongoMapper::Document
  
  key :location, Array
  key :count, Integer
  key :year, String
  key :zoom, Integer
  
  BATCH_SIZE = 10000
  
  def self.build year
    puts "Fetching located crashes that occurred in #{year}..."
    
    # Due to MongoDB's "too much data for sort() with no index. add an index or specify a smaller limit" error,
    # we must unfortunately do our sort in Ruby.
    crashes = Crash.all({
      :year => year,
      :location => { '$exists' => true }
    }).sort { |a, b| a.location <=> b.location }
    
    CrashCluster.collection.remove(year: year)
    (5..15).each do |zoom|
      puts "Building #{year} cluster at zoom #{zoom}..."
      clusters = Cluster.new.find_by crashes, 20, zoom
      clusters.each do |cluster|
        crash_cluster = CrashCluster.new year: year, count: cluster.size, zoom: zoom
        crash_cluster.location = [
          cluster.map { |c| c.location[0] }.inject(0) { |sum, longitude| sum + longitude } / cluster.size,
          cluster.map { |c| c.location[1] }.inject(0) { |sum, latitude| sum + latitude } / cluster.size
        ]
        crash_cluster.save
      end
    end
  end
  
  def as_json options = {}
    {
      year: self.year,
      count: self.count,
      location: self.location
    }
  end
end