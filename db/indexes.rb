Crash.ensure_index [[:year, 1], [:lng, 1], [:lat, 1]]
Crash.ensure_index [[:_type, 1], [:year, 1]]
Code.ensure_index [[:type, 1], [:value, 1], [:_id, 1]]
#StateCrash.ensure_index '_id.year'
#CountyCrash.ensure_index '_id.year'
#CountyCrash.ensure_index [['value.location', '2d'], ['_id.year', 1]]
#CityCrash.ensure_index '_id.year'
#CityCrash.ensure_index [['value.location', '2d'], ['_id.year', 1]]
Cluster.ensure_index [[:year, 1], [:zoom, 1], [:lng, 1], [:lat, 1]]