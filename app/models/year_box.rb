class YearBox
  include MongoMapper::Document
  
  key :value, Hash
  
  def self.map
    <<-MAP
      function() {
        emit({
          year: this.year,
          user_id: userId
        }, 1);
      }
    MAP
  end
  
  def self.reduce
    <<-REDUCE
      function(key, values) {
        var sum = 0;
        values.forEach(function(value) {
          sum += value;
        });
        return sum;
      }
    REDUCE
  end
  
  def self.build box
    Crash.collection.map_reduce(map, reduce, {
      out: { merge: "year_boxes" },
      scope: { userId: box.user.id },
      query: {
        lat: { '$gte' => box.sw_lat, '$lte' => box.ne_lat },
        lng: { '$gte' => box.sw_lng, '$lte' => box.ne_lng }
      }
    })
  end
  
  def as_json options = {}
    {
      year: self.id['year'],
      count: self.value
    }
  end
end