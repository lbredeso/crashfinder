module Reports
  class CrashesByLocrel
    include MongoMapper::Document
    extend MapReduce
    
    key :locrel, String
    key :crashes, Integer
    
    def self.map
      <<-MAP
        function() {
          emit(this.locrel, 1);
        }
      MAP
    end
    
    def self.build
      crashes_by_locrel = Crash.collection.map_reduce(map, sum, { :out => "crashes_by_locrel" }).find()
      CrashesByLocrel.collection.drop()
      crashes_by_locrel.each do |l|
        CrashesByLocrel.create(:locrel => l['_id'], :crashes => l['value'])
      end
    end
  end
end