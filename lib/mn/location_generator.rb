BATCH_SIZE = 1000

module MN
  class LocationGenerator
    def generate year
      last_page = Crash.count(:year => year, :locrel => ['1', '2', '3']) / BATCH_SIZE + 1
      puts "Generating crash location file for #{year}"
      CSV.open("mn-#{year}-loc.csv", "wb") do |csv|
        current_page = 1
        until current_page > last_page
          crashes = Crash.paginate({
            :year => year,
            :locrel => ['1', '2', '3'],
            :order => :_id,
            :per_page => BATCH_SIZE,
            :page => current_page
          })
          crashes.each do |crash|
            # When the rtnumber ends in 8888 or 9999, it is invalid.  This can happen when it is
            # known which road the crash occurred on, just not precisely where on that road.
            if crash.rtnumber !~ /9999$/ and crash.rtnumber !~ /8888$/
              csv << [crash.id, crash.route_id, crash.mile_point]
            end
          end
          current_page += 1
        end
      end
    end
  end
end