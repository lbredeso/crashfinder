module Reports
  class CrashesByMonth
    include MongoMapper::Document
    
    key :month, String
    key :crashes, Integer
    
    def self.map
      <<-MAP
        function() {
          emit(this.month, 1);
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
      crashes_by_month = Crash.collection.map_reduce(map, reduce, { :out => "crashes_by_month" }).find()
      CrashesByMonth.collection.drop()
      crashes_by_month.each do |m|
        CrashesByMonth.create(:month => m['_id'], :crashes => m['value'])
      end
    end
  end
end