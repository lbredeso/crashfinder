class Code
  include MongoMapper::Document

  key :value, String
  key :type, String
  
  def self.key_map type
    Code.where(type: type).all.inject({}) { |map, cc| map[cc.id] = cc.value; map } || {}
  end
  
  def self.value_map type
    Code.where(type: type).all.inject({}) { |map, cc| map[cc.value] = cc.id; map } || {}
  end
  
  def self.map
    Code.collection.distinct(:type).inject({}) do |map, type|
      map[type] = key_map type
      map
    end
  end

end
