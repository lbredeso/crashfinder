class Crash
  include MongoMapper::Document
  
  ACTIVE = [:_id, :accdate, :city, :city_township, :city_township_name, :county, :county_name, :day, :location, :locrel, :mile_point, :month, :route_id, :rtnumber, :rtsys, :weekday, :year]
  
  many :people
  many :vehicles
  
  # DPS fields
  key :accdate, String
  key :accday, String
  key :accsev, String
  key :acctim2, String
  key :acctype, String
  key :acmonth, String # Bug: DPS only includes 1 of 2 required characters; thankfully, we have accdate
  key :agency, String
  key :bridge, String
  key :city, String
  key :ciorto, String
  key :county, String
  key :diagram, String
  key :funclas, String
  key :hitrun, String
  key :intrel, String
  key :light, String
  key :loccase, String
  key :locfhe, String
  key :locrel, String
  key :locwz, String
  key :numfat, Integer
  key :numinj, Integer
  key :nummv, Integer
  key :officer, String
  key :online, String
  key :patsta, String
  key :photos, String
  key :popcity, Integer
  key :propdam, String
  key :rdchar, String
  key :rddes, String
  key :rddirect, String
  key :rdsurf, String
  key :rdwork, String
  key :refpt, String
  key :rtnumber, String
  key :rtsys, String
  key :sbusoff, String
  key :speed, String
  key :tiscity, String
  key :tiscoun, String
  key :trfcntl, String
  key :truem1, String
  key :truem2, String
  key :truem3, String
  key :urbcat, String
  key :urbrurt, String
  key :weather, String
  key :weath2, String
  key :workers, String
  key :working, String
  key :xcoord, Integer
  key :ycoord, Integer
  
  # Added fields
  key :route_id, String
  key :mile_point, Float
  key :month, String
  key :day, String
  key :year, String
  key :weekday, String
  key :location, Array
  
  # Coded values
  key :city_township, String
  key :city_township_name, String
  key :county_name
  
  def as_json options = {}
    {
      year: self.year,
      location: self.location
    }
  end
  
end