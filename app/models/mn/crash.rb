class MN::Crash < Crash
  ACTIVE = [:accn, :month, :day, :year, :weekday, :time, :lng, :lat, :accdate, :locrel, :mile_point, :refpt1, :refpt2, :route_id, :rtnumber, :rtsys, :truem1, :truem3]
  
  many :people
  many :vehicles
  
  # DPS fields
  key :accdate, String
  key :city, String
  key :county, String
  key :locrel, String
  key :refpt1, String
  key :refpt2, String
  key :rtnumber, String
  key :rtsys, String
  key :truem1, String
  key :truem2, String
  key :truem3, String
  
  # Added fields
  key :route_id, String
  key :mile_point, Float
  
  # Coded values
  key :city_township, String
  key :city_township_name, String
  key :county_name
end
