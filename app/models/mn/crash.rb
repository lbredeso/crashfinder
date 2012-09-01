class MN::Crash < Crash
  ACTIVE = [:accn, :month, :day, :year, :weekday, :time, :lng, :lat, :accdate, :locrel, :mile_point, :route_id, :rtnumber, :rtsys, :truem1, :truem3]
  
  many :people
  many :vehicles
  
  # DPS fields
  key :accn, String
  key :accdate, String
  key :city, String
  key :county, String
  key :locrel, String
  key :refpt, String
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
