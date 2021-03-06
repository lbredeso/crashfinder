class StateCrash
  include MongoMapper::Document
  
  key :value, Hash
  
  def self.map
    <<-MAP
      function() {
        if (this.location) {
          emit({
            year: this.year
          }, {
            latitude_sum: this.location[0],
            longitude_sum: this.location[1],
            count: 1
          });
        }
      }
    MAP
  end
  
  def self.reduce
    <<-REDUCE
      function(key, values) {
        var r = { latitude_sum: 0.0, longitude_sum: 0.0, count: 0 };
        values.forEach(function(v) {
          r.latitude_sum += v.latitude_sum;
          r.longitude_sum += v.longitude_sum;
          r.count += v.count;
        });
        return r;
      }
    REDUCE
  end
  
  def self.finalize
    <<-FINALIZE
      function(key, value) {
        value.location = [
          (value.latitude_sum / value.count),
          (value.longitude_sum / value.count)
        ];
      }
      return value;
    FINALIZE
  end
  
  def self.build
    Crash.collection.map_reduce(map, reduce, { :out => "state_crashes", :finalize => finalize })
  end
  
  def as_json options = {}
    {
      year: self.id['year'],
      count: self.value['count'],
      location: self.value['location']
    }
  end
end