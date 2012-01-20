module Reports
  class VehiclesByColor
    include MongoMapper::Document
    
    key :color, String
    key :vehicles, Integer
    
    def self.map
      <<-MAP
        function() {
          this.vehicles.forEach(function(vehicle) {
            emit(vehicle.vehcolor, 1);
          });
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
    
    def self.build
      vehicles_by_color = Crash.collection.map_reduce(map, reduce, { :out => "by_weekday" }).find()
      VehiclesByColor.collection.drop()
      vehicles_by_color.each do |c|
        VehiclesByColor.create(:color => c['_id'], :vehicles => c['value'])
      end
    end
  end
end