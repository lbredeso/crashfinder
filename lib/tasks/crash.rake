require 'mn/crash_converter'
require 'set'
require 'csv'

BATCH_SIZE = 1000

namespace :crashes do
  desc "Load crash data"
  task :load, [:state, :start_year, :end_year] => :environment do |t, args|
    state = args.state
    state_module = self.class.const_get(state.upcase.to_sym)
    crash_converter = state_module::CrashConverter.new
    
    start_year = args.start_year.to_i
    end_year = args.end_year ? args.end_year.to_i : start_year
    
    (start_year..end_year).each do |year|
      puts "Loading crash data for #{year}"
      year_file = File.join Rails.root, "lib", "data", "mn", crash_converter.file_name(year)
      crashes = []
      File.open(year_file).each_line do |line|
        crashes << crash_converter.convert(line)
        if crashes.size % BATCH_SIZE == 0
          puts "Saving..."
          state_module::Crash.collection.insert crashes
          crashes = []
        end
      end
      puts "Saving..."
      state_module::Crash.collection.insert crashes
    end
  end
  
  desc "Generate location file"
  task :generate_location_file, [:year] => :environment do |t, args|
    year = args.year
    last_page = Crash.count(:year => year, :locrel => ['1', '2', '3']) / BATCH_SIZE + 1
    puts "Generating crash location file for #{year}"
    CSV.open("mn-#{year}-loc.csv", "wb") do |csv|
      current_page = 1
      until current_page > last_page
        crashes = Crash.paginate({
          :year => year,
          :locrel => ['1', '2', '3'],
          :order => :accn,
          :per_page => BATCH_SIZE,
          :page => current_page
        })
        crashes.each do |crash|
          # When the rtnumber ends in 8888 or 9999, it is invalid.  This can happen when it is
          # known which road the crash occurred on, just not precisely where on that road.
          if crash.rtnumber !~ /9999$/ and crash.rtnumber !~ /8888$/
            csv << [crash.accn, crash.route_id, crash.mile_point]
          end
        end
        current_page += 1
      end
    end
  end
  
  desc "Update locations from given file"
  task :update_locations, [:file] => :environment do |t, args|
    file = args.file
    puts "Updating locations from #{file}"
    CSV.foreach("lib/data/location/#{file}") do |row|
      crash = Crash.find row[0]
      puts "Update crash location for accn #{crash.id}"
      crash.update_attributes lng: row[1].to_f, lat: row[2].to_f
    end
  end
  
  desc "Build crash map reduce collections"
  task :map_reduce => :environment do
    puts "Creating state_crashes collection..."
    StateCrash.build
    
    puts "Creating county_crashes collection..."
    CountyCrash.build
    
    puts "Creating city_crashes collection..."
    CityCrash.build
  end
  
  desc "Build clusters"
  task :build_clusters, [:start_year, :end_year, :zoom] => :environment do |t, args|
    start_year = args.start_year.to_i
    end_year = args.end_year ? args.end_year.to_i : start_year
    zoom = args.zoom
    (start_year..end_year).each do |year|
      if zoom
        CrashCluster.build year.to_s, [zoom.to_i]
      else
        CrashCluster.build year.to_s, (5..15)
      end
    end
  end
end

def bulk_save type, things
  accns = Set.new(things.map { |t| t.accn }).to_a
  crashes = Crash.where(:id => accns).all.inject({}) do |crashes, crash|
    crashes[crash.id] = crash
    crashes
  end
  things.each do |thing|
    if crashes[thing.accn]
      crashes[thing.accn].send(type.to_s.downcase.pluralize) << thing
    else
      puts "Crash #{thing.accn} not found!  Better investigate..."
    end
  end
  crashes.values.each do |crash|
    crash.save
  end
end
