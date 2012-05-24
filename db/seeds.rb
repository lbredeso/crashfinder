require 'csv'

# Create county names
County.collection.drop

seeds = File.join Rails.root, 'db', 'seeds'

CSV.foreach "#{seeds}/counties.csv" do |row|
  County.create id: row[0], name: row[1]
end