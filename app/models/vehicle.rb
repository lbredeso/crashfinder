class Vehicle
  include MongoMapper::EmbeddedDocument
  
  # No point saving this, since it's already embedded in the crash
  attr_accessor :accn
  
  key :action, Integer
  key :cargotp, Integer
  key :cfct1, Integer
  key :cfct2, Integer
  key :damarea, Integer
  key :damsev, Integer
  key :directn, Integer
  key :event1, Integer
  key :event2, Integer
  key :event3, Integer
  key :event4, Integer
  key :fire, String
  key :hazplac, String
  key :make, String
  key :mosthe, Integer
  key :rvn, Integer
  key :series, String
  key :totocc, Integer
  key :towaway, String
  key :towing, String
  key :vehcolor, String
  key :vehtype, Integer
  key :vehuse, Integer
  key :vehyear, String
  key :waived, String
  
end