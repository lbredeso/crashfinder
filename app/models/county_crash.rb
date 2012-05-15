class CountyCrash
  include MongoMapper::Document
  
  key :value, Hash
  
  def self.map
    <<-MAP
      function() {
        if (this.location) {
          emit({
            county: this.county.toString(), year: this.year
          }, {
            latitude: this.location[0],
            longitude: this.location[1],
            count: 1
          });
        }
      }
    MAP
  end
  
  def self.reduce
    <<-REDUCE
      function(key, values) {
        var r = { county: key['county'], year: key['year'], latitude: 0.0, longitude: 0.0, count: 0 };
        values.forEach(function(v) {
          r.latitude += v.latitude;
          r.longitude += v.longitude;
          r.count += v.count;
        });
        return r;
      }
    REDUCE
  end
  
  def self.finalize
    <<-FINALIZE
      function(key, value) {
        value.avg_latitude = value.latitude / value.count;
        value.avg_longitude = value.longitude / value.count;
      }
      return value;
    FINALIZE
  end
  
  def self.build
    Crash.collection.map_reduce(map, reduce, { :out => "county_crashes", :finalize => finalize })
  end
end