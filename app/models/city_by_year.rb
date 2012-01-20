class CityByYear
  def self.map
    <<-MAP
      function() {
        emit({ city: this.city, year: this.year }, 1);
      }
    MAP
  end
  
  def self.reduce
    <<-REDUCE
      function(key, values) {
        var sum = 0;
        for (var i in values) sum += values[i];
        return sum;
      }
    REDUCE
  end
  
  def self.build
    Crash.collection.map_reduce(map, reduce, { :out => "cityByYear" })
  end
end