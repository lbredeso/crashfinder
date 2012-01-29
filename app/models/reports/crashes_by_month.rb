module Reports
  class CrashesByMonth
    include MongoMapper::Document
    extend MapReduce
    
    key :month, String
    key :crashes, Integer
    
    def self.map
      <<-MAP
        function() {
          emit(this.month, 1);
        }
      MAP
    end
    
    def self.build
      crashes_by_month = Crash.collection.map_reduce(map, sum, { :out => "crashes_by_month" }).find()
      CrashesByMonth.collection.drop()
      crashes_by_month.each do |m|
        CrashesByMonth.create(:month => m['_id'], :crashes => m['value'])
      end
    end
  end
end