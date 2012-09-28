class YearStat
  include MongoMapper::Document
  
  key :value, Hash
  
  def self.map
    <<-MAP
      function() {
        emit({
          location_id: locationId,
          year: this.year
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
  
  def self.build location
    Crash.collection.map_reduce(map, reduce, {
      out: { merge: "year_stats" },
      scope: { locationId: location.id },
      query: {
        lat: { '$gte' => location.sw_lat, '$lte' => location.ne_lat },
        lng: { '$gte' => location.sw_lng, '$lte' => location.ne_lng }
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