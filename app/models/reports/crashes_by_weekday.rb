module Reports
  class CrashesByWeekday
    include MongoMapper::Document
    
    key :weekday, String
    key :crashes, Integer
    
    def self.map
      <<-MAP
        function() {
          emit(this.weekday, 1);
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
      crashes_by_weekday = Crash.collection.map_reduce(map, reduce, { :out => "crashes_by_weekday" }).find()
      CrashesByWeekday.collection.drop()
      crashes_by_weekday.each do |w|
        CrashesByWeekday.create(:weekday => w['_id'], :crashes => w['value'])
      end
    end
  end
end