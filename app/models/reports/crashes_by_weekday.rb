module Reports
  class CrashesByWeekday
    include MongoMapper::Document
    extend MapReduce
    
    key :weekday, String
    key :crashes, Integer
    
    def self.map
      <<-MAP
        function() {
          emit(this.weekday, 1);
        }
      MAP
    end
    
    def self.build
      crashes_by_weekday = Crash.collection.map_reduce(map, sum, { :out => "crashes_by_weekday" }).find()
      CrashesByWeekday.collection.drop()
      crashes_by_weekday.each do |w|
        CrashesByWeekday.create(:weekday => w['_id'], :crashes => w['value'])
      end
    end
  end
end