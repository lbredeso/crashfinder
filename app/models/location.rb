class Location
  include MongoMapper::Document
  
  attr_protected :user_id

  belongs_to :user

  key :label, String
  key :zoom, Integer
  key :sw_lat, Float
  key :sw_lng, Float
  key :ne_lat, Float
  key :ne_lng, Float
  
  before_save do |location|
    location.label = location.id unless location.label
  end
  
  after_save do |location|
    YearStat.build location
    MonthStat.build location
  end
  
  def as_json options = {}
    {
      label: self.label,
      zoom: self.zoom,
      center_lat: (self.sw_lat + self.ne_lat) / 2,
      center_lng: (self.sw_lng + self.ne_lng) / 2,
      sw_lat: self.sw_lat,
      sw_lng: self.sw_lng,
      ne_lat: self.ne_lat,
      ne_lng: self.ne_lng
    }
  end

end
