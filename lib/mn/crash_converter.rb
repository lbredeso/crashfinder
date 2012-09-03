module MN
  class CrashConverter
    def initialize year
      @year = year
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
      crash[:_id] = "MN-#{crash[:accn]}"
      crash.delete :accn
      crash[:_type] = "MN::Crash"
      
      # Location info varies a bit between v1 and v2
      if version == :v1
        crash[:route_id] = pad_route_id(crash[:rtsys][1..2], crash[:rtnumber])
        crash[:refpt1] = sanitize_refpt1 crash[:refpt1]
        crash[:refpt2] = sanitize_refpt2 crash[:refpt2]
        crash[:mile_point] = "#{crash[:refpt1]}.#{crash[:refpt2]}".to_f
        crash.delete :refpt1
        crash.delete :refpt2
      else
        crash[:route_id] = crash[:rtsys][1..2] + pad_rtnumber(crash[:rtnumber])
        crash[:mile_point] = "#{crash[:truem1]}.#{crash[:truem3]}".to_f
        crash.delete :truem1
        crash.delete :truem3
      end
      crash.delete :rtsys
      crash.delete :rtnumber
      crash[:accdate] =~ /([\d]{2})\/([\d]{2})\/([\d]{4})/
      crash[:month] = $1
      crash[:day] = $2
      crash[:year] = $3
      crash[:weekday] = Date.strptime(crash[:accdate], "%m/%d/%Y").strftime("%A")
      
      if Crash::ACTIVE.include? :city
        # Townships are a weird case, as they are uniquely identified by county + township code
        # They also are thrown in with the city code, in cases where the city isn't known (e.g. rural crashes).
        crash[:city_township] = if crash[:city].size == 3
          "#{crash[:county]}#{crash[:city]}"
        else
          crash[:city]
        end
        crash[:city_township_name] = @code_map['city_township'][crash[:city_township]]
      end
      
      crash
    end
    
    def file_name
      "crash/mn-#{@year}-acc.txt"
    end
    
    private 
    def version
      case
      when @year.to_i <= 2002
        :v1
      when @year.to_i >= 2004
        :v2
      end
    end
    
    def process_layout type, pattern
      file = File.join Rails.root, "lib", "mn", "field_layout", version.to_s, "#{type}.txt"
      puts "Using layout #{file}"
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
    
    def pad_route_id rtsys, rtnumber
      size = if rtnumber =~ /[A-Z]/
        11
      else
        10
      end
      
      "#{rtsys}#{rtnumber.rjust(size - rtsys.size, '0')}"
    end
    
    # Looks like this is empty sometimes, except for a period (in 1991, at least).
    def sanitize_refpt1 refpt1
      refpt1.strip.gsub(".", "")
    end
    
    # Looks like this is empty sometimes, except for a period (in 1991, at least).
    # Mostly, however, we need to strip out the "00.".  I think it's like truem2, which I'm told is virtually always 00.
    def sanitize_refpt2 refpt2
      refpt2.strip.gsub(/0[\d]{1}\./, "").gsub(".", "")
    end
    
    class Field < Struct.new(:start, :name, :length)
    end
  end
end
