require 'csv'

# Create code mappings
Code.collection.drop

seeds = File.join Rails.root, 'db', 'seeds'

# Save non-township mappings
Dir.open(seeds).each do |file|
  type = File.basename file, '.csv'
  unless ['.', '..'].include? file
    seedfile = File.join seeds, file
    unless type == 'township'
      CSV.foreach seedfile do |row|
        Code.create id: row[0], value: row[1].strip.titleize, type: type
      end
    end
  end
end

# Save township mappings
seedfile = File.join seeds, 'township.csv'
county_codes = Code.where(type: 'county').all.inject({}) { |total, cc| total[cc.value] = cc.id; total }

CSV.foreach seedfile do |row|
  township = row[1][1..3]
  Code.create id: "#{county_codes[row[3].titleize]}#{township}", value: "#{row[0].strip} Township".titleize, type: 'city_township'
end

Code.where(type: 'city').all.each do |city_code|
  Code.create id: city_code.id, value: city_code.value, type: 'city_township'
end