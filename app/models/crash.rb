class Crash
  include MongoMapper::Document
  
  many :people
  many :vehicles
  
  # DPS fields
  key :accdate, String
  key :accday, Integer
  key :accn, String
  key :accsev, String
  key :acctim2, Integer
  key :acctype, Integer
  key :acmonth, Integer
  key :agency, String
  key :bridge, String
  key :city, String
  key :ciorto, String
  key :county, Integer
  key :diagram, Integer
  key :funclas, Integer
  key :hitrun, String
  key :intrel, Integer
  key :light, Integer
  key :loccase, Integer
  key :locfhe, Integer
  key :locrel, Integer
  key :locwz, Integer
  key :numfat, Integer
  key :numinj, Integer
  key :nummv, Integer
  key :officer, Integer
  key :online, String
  key :patsta, Integer
  key :photos, String
  key :popcity, Integer
  key :propdam, String
  key :rdchar, Integer
  key :rddes, Integer
  key :rddirect, String
  key :rdsurf, Integer
  key :rdwork, Integer
  key :refpt, String
  key :rtnumber, String
  key :rtsys, String
  key :sbusoff, Integer
  key :speed, String
  key :tiscity, Integer
  key :tiscoun, Integer
  key :trfcntl, Integer
  key :truem1, String
  key :truem2, String
  key :truem3, String
  key :urbcat, Integer
  key :urbrurt, Integer
  key :weather, Integer
  key :weath2, Integer
  key :workers, String
  key :working, Integer
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

end