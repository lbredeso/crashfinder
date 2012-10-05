class MonthStat
  include MongoMapper::Document
  
  key :value, Integer
  
  scope :by_user, lambda { |user| where('_id.user_id' => user.id) }
  scope :in_order, sort('_id.location_id', '_id.year')
  
  def self.map
    <<-MAP
      function() {
        emit({
          location_id: locationId,
          label: label,
          user_id: userId,
          month: this.month
        }, 1);
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
  
  def self.build location
    Crash.collection.map_reduce(map, reduce, {
      out: { merge: "month_stats" },
      scope: { locationId: location.id, label: location.label, userId: location.user.id },
      query: {
        lat: { '$gte' => location.sw_lat, '$lte' => location.ne_lat },
        lng: { '$gte' => location.sw_lng, '$lte' => location.ne_lng }
      }
    })
  end
  
  def as_json options = {}
    {
      locationId: self.id['location_id'],
      label: self.id['label'],
      month: self.id['month'].to_i - 1,
      count: self.value
    }
  end
end