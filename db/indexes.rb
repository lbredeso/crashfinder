Crash.ensure_index [[:location, '2d'], [:year, 1]]
Code.ensure_index [[:type, 1], [:value, 1], [:_id, 1]]
StateCrash.ensure_index '_id.year'
CountyCrash.ensure_index '_id.year'
CountyCrash.ensure_index [['value.location', '2d'], ['_id.year', 1]]
CityCrash.ensure_index '_id.year'
CityCrash.ensure_index [['value.location', '2d'], ['_id.year', 1]]
Crash.ensure_index [[:locrel, 1], [:year, 1]]
CrashCluster.ensure_index [[:location, '2d'], [:zoom, 1], [:year, 1]]