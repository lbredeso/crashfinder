require 'set'
require 'csv'

DATE_RANGE = (2004..2010)
BATCH_SIZE = 1000

namespace :crashes do
  desc "Load crash data"
  task :load, [:start_year, :end_year] => :environment do |t, args|
    start_year = args.start_year.to_i
    end_year = args.end_year ? args.end_year.to_i : start_year
    (start_year..end_year).each do |year|
      layout = process_layout Crash, "A7A9A9"
      puts "Loading crash data for #{year}"
      year_file = File.join Rails.root, "lib", "data", "crash", "mn-#{year}-acc.txt"
      crashes = []
      code_map = Code.map
      File.open(year_file).each_line do |line|
        crash = {}
        data = line.unpack layout[:pattern]
        puts "Loading #{year} crash for accn #{data[1]}"
        
        layout[:fields].each_with_index do |field, index|
          converter = case layout[:field_types][field.name]
            when "Integer" then "to_i"
            when "String" then "to_s"
            else "to_s"
          end
          if Crash::ACTIVE.include? field.name.intern
            crash[field.name.intern] = data[index].send(converter)
            if code_map[field.name]
              crash["#{field.name}_name"] = code_map[field.name][crash[field.name.intern]]
            end
          end
        end
        crash[:route_id] = crash[:rtsys][1..2] + pad_rtnumber(crash[:rtnumber])
        crash[:mile_point] = "#{crash[:truem1]}.#{crash[:truem3]}".to_f
        crash[:accdate] =~ /([\d]{2})\/([\d]{2})\/([\d]{4})/
        crash[:month] = $1
        crash[:day] = $2
        crash[:year] = $3
        crash[:weekday] = Date.strptime(crash[:accdate], "%m/%d/%Y").strftime("%A")
        
        # Townships are a weird case, as they are uniquely identified by county + township code
        # They also are thrown in with the city code, in cases where the city isn't known (e.g. rural crashes).
        crash[:city_township] = if crash[:city].size == 3
          "#{crash[:county]}#{crash[:city]}"
        else
          crash[:city]
        end
        crash[:city_township_name] = code_map['city_township'][crash[:city_township]]
        
        crashes << crash
        if crashes.size % BATCH_SIZE == 0
          puts "Saving..."
          Crash.collection.insert crashes
          crashes = []
        end
      end
      puts "Saving..."
      Crash.collection.insert crashes
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
      crash.update_attributes :location => [row[1].to_f, row[2].to_f]
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
  task :build_clusters, [:start_year, :end_year] => :environment do |t, args|
    beginning_time = Time.now
    start_year = args.start_year.to_i
    end_year = args.end_year ? args.end_year.to_i : start_year
    (start_year..end_year).each do |year|
      CrashCluster.build year.to_s
    end
    end_time = Time.now
    puts "Cluster building took #{end_time - beginning_time} seconds"
  end
end

namespace :vehicles do
  desc "Load vehicle data"
  task :load, [:year] => :environment do |t, args|
    year = args.year
    layout = process_layout Vehicle, "A5A9A9"
    puts "Loading vehicle data for #{year}"
    year_file = File.join Rails.root, "lib", "data", "vehicle", "mn-#{year}-veh.txt"
    vehicles = []
    File.open(year_file).each_line do |line|
      data = line.unpack layout[:pattern]
      vehicle = Vehicle.new
      
      layout[:fields].each_with_index do |field, index|
        converter = case layout[:field_types][field.name]
          when "Integer" then "to_i"
          when "String" then "to_s"
          else "to_s"
        end
        if Vehicle::ACTIVE.include? field.name.intern
          vehicle.send "#{field.name}=", data[index].send(converter)
        end
      end
      puts "Loading #{year} vehicle for accn #{vehicle.accn}"
      vehicles << vehicle
      if vehicles.size % BATCH_SIZE == 0
        puts "Saving..."
        bulk_save Vehicle, vehicles
        vehicles = []
      end
    end
    puts "Saving..."
    bulk_save Vehicle, vehicles
  end
end

namespace :people do
  desc "Load person data"
  task :load, [:year] => :environment do |t, args|
    year = args.year
    layout = process_layout Person, "A5A9A9"      
    puts "Loading person data for #{year}"
    year_file = File.join Rails.root, "lib", "data", "person", "mn-#{year}-per.txt"
    people = []
    Crash.collection.update({ :year => year }, { '$unset' => { 'people' => 1 } }, :upsert => false, :multi => true)
    File.open(year_file).each_line do |line|
      data = line.unpack layout[:pattern]
      person = Person.new
      
      layout[:fields].each_with_index do |field, index|
        converter = case layout[:field_types][field.name]
          when "Integer" then "to_i"
          when "String" then "to_s"
          else "to_s"
        end
        if Person::ACTIVE.include? field.name.intern
          person.send "#{field.name}=", data[index].send(converter)
        end
      end
      puts "Loading #{year} person for accn #{person.accn}"
      people << person
      if people.size % BATCH_SIZE == 0
        puts "Saving..."
        bulk_save Person, people
        people = []
      end
    end
    puts "Saving..."
    bulk_save Person, people
  end
end

def process_layout type, pattern
  file = File.join Rails.root, "lib", "field_layout", "#{type.to_s.downcase}.txt"
  fields = []
  File.open(file).each_line do |line|
    start, name, type_length = line.unpack pattern
    field = Field.new
    field.start = start.gsub("@", "").to_i
    field.name = name.downcase
    length = /(\$|Z|MMDDYY)(\d{1,2})\.0?/.match(type_length)[2]
    field.length = length.to_i
    fields << field
  end
  fields.sort! { |a, b| a.start <=> b.start }
  
  pattern = fields.map { |f| "@#{f.start-1}A#{f.length}" }.join
  field_types = type.keys.inject({}) { |field_types, key| field_types[key.first] = key.last.type.to_s; field_types }
  
  { :fields => fields, :pattern => pattern, :field_types => field_types }
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

# rtnumber should always be 10 digits, except when it contains a letter;
# then it must be 11.  This is to correctly align with TIS_CODE in the shapefiles.
def pad_rtnumber rtnumber
  if rtnumber =~ /[A-Z]/
    "0#{rtnumber}"
  else
    rtnumber
  end
end

class Field < Struct.new(:start, :name, :length)
end