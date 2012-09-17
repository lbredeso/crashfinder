class Box
  include MongoMapper::Document

  belongs_to :user

  key :label, String
  key :sw_lat, Float
  key :sw_lng, Float
  key :ne_lat, Float
  key :ne_lng, Float
  
  after_save do |box|
    YearBox.build box
  end

end
