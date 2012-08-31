module MN
  class CrashConverter
    def initialize
      @layout = process_layout "crash", "A7A9A9"
      @code_map = Code.map
    end
    
    def convert line
      crash = {}
      data = line.unpack @layout[:pattern]
      puts "Loading MN crash for accn #{data[1]}"
      
      @layout[:fields].each_with_index do |field, index|
        converter = case @layout[:field_types][field.name]
          when "Integer" then "to_i"
          when "String" then "to_s"
          else "to_s"
        end
        if Crash::ACTIVE.include? field.name.intern
          crash[field.name.intern] = data[index].send(converter)
          if @code_map[field.name]
            crash["#{field.name}_name"] = @code_map[field.name][crash[field.name.intern]]
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
      crash[:city_township_name] = @code_map['city_township'][crash[:city_township]]
      
      crash
    end
    
    def file_name year
      "crash/mn-#{year}-acc.txt"
    end
    
    private
    def process_layout type, pattern
      file = File.join Rails.root, "lib", "mn", "field_layout", "#{type}.txt"
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
      field_types = self.class.const_get(type.capitalize.to_sym).keys.inject({}) { |field_types, key| field_types[key.first] = key.last.type.to_s; field_types }
      
      { :fields => fields, :pattern => pattern, :field_types => field_types }
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
  end
end
