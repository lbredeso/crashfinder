require 'clusterer'

class Cluster
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
      :lng => { '$exists' => true }
    }).sort { |a, b| a.lng <=> b.lng }
    
    zoom_levels.each do |zoom|
      Clusterer.new.execute year, crashes, 20, zoom
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