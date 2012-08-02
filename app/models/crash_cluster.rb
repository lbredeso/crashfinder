require 'cluster'

class CrashCluster
  include MongoMapper::Document
  
  key :location, Array
  key :count, Integer
  key :year, String
  key :zoom, Integer
  
  def self.build year
    CrashCluster.collection.drop()
    puts "Fetching located crashes that occurred in #{year}..."
    crashes = Crash.where({'year' => year, 'location' => { '$exists' => true }}).sort(:location).all
    (5..15).each do |zoom|
      puts "Building #{year} cluster at zoom #{zoom}..."
      clusters = Cluster.new.find_by crashes, 10, zoom
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
end