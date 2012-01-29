module Reports::MapReduce
  def sum
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
end