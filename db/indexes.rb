Crash.ensure_index :accn, :unique => true
Crash.ensure_index [[:city, 1], [:year, 1]]
Crash.ensure_index [[:county, 1], [:year, 1]]
Crash.ensure_index :day
Crash.ensure_index [[:locrel, 1], [:year, 1]]
Crash.ensure_index [[:location, '2d']]
Crash.ensure_index [[:location, '2d'], [:year, 1]]
Crash.ensure_index :month
Crash.ensure_index :weekday
Crash.ensure_index :year
Crash.ensure_index "vehicles.vehcolor"
Code.ensure_index [[:type, 1], [:value, 1], [:_id, 1]]
StateCrash.ensure_index '_id.year'
CountyCrash.ensure_index '_id.year'
CityCrash.ensure_index '_id.year'