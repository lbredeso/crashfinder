class Crash
  include MongoMapper::Document
  
  key :month, String
  key :day, String
  key :year, String
  key :weekday, String
  key :hour, String
  key :lng, Float
  key :lat, Float
  
  def as_json options = {}
    {
      year: self.year,
      lng: self.lng,
      lat: self.lat
    }
  end
end
