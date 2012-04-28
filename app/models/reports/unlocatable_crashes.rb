module Reports
  class UnlocatableCrashes
    include MongoMapper::Document
    extend MapReduce
    
    key :locrel, String
    key :crashes, Integer
    
    def self.map
      <<-MAP
        function() {
          if (!this.location) {
            emit(this.year, 1);
          }
        }
      MAP
    end
    
    def self.build
      unlocatable_crashes = Crash.collection.map_reduce(map, sum, { :out => "unlocatable_crashes" }).find()
      UnlocatableCrashes.collection.drop()
      unlocatable_crashes.each do |l|
        UnlocatableCrashes.create(:locrel => l['_id'], :crashes => l['value'])
      end
    end
  end
end