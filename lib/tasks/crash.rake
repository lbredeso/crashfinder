require 'mn/crash_converter'
require 'mn/location_generator'
require 'nd/crash_converter'
require 'set'
require 'csv'

BATCH_SIZE = 1000

namespace :crash do
  desc "Load crash data"
  task :load, [:state, :start_year, :end_year] => :environment do |t, args|
    state = args.state
    state_module = self.class.const_get(state.upcase.to_sym)
    
    start_year = args.start_year.to_i
    end_year = args.end_year ? args.end_year.to_i : start_year
    
    (start_year..end_year).each do |year|
      crash_converter = state_module::CrashConverter.new year
      
      year_file = File.join Rails.root, "lib", "data", state, crash_converter.file_name
      puts "Loading crash data from #{year_file}"
      crashes = []
      File.open(year_file).each_line do |line|
        crash = crash_converter.convert(line)
        crashes << crash if crash
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
  
  desc "Load crash data from a file"
  task :load_file, [:state, :file] => :environment do |t, args|
    state = args.state
    state_module = self.class.const_get(state.upcase.to_sym)
    file = args.file
    
    crash_converter = state_module::CrashConverter.new
    crashes = []
    File.open("lib/data/#{state}/#{file}").each_line do |line|
      crash = crash_converter.convert(line)
      crashes << crash if crash
      if crashes.size % BATCH_SIZE == 0
        puts "Saving..."
        state_module::Crash.collection.insert crashes
        crashes = []
      end
    end
    puts "Saving..."
    state_module::Crash.collection.insert crashes
  end
  
  desc "Generate location file"
  task :generate_location_file, [:state, :start_year, :end_year] => :environment do |t, args|
    state = args.state
    start_year = args.start_year.to_i
    end_year = args.end_year ? args.end_year.to_i : start_year
    
    location_generator = self.class.const_get(state.upcase.to_sym)::LocationGenerator.new
    (start_year..end_year).each do |year|
      location_generator.generate year.to_s
    end
  end
  
  desc "Update locations from given file"
  task :update_locations, [:state, :file] => :environment do |t, args|
    state = args.state
    file = args.file
    puts "Updating locations for #{state} from #{file}"
    CSV.foreach("lib/data/#{state}/location/#{file}") do |row|
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
        Cluster.build year.to_s, [zoom.to_i]
      else
        Cluster.build year.to_s, (5..16)
      end
    end
  end
end
