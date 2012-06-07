Crash.ensure_index :accn, :unique => true
Crash.ensure_index [[:location, '2d'], [:year, 1]]
Code.ensure_index [[:type, 1], [:value, 1], [:_id, 1]]
StateCrash.ensure_index '_id.year'
CountyCrash.ensure_index '_id.year'
CountyCrash.ensure_index [['value.location', '2d'], ['_id.year', 1]]
CityCrash.ensure_index '_id.year'
CityCrash.ensure_index [['value.location', '2d'], ['_id.year', 1]]