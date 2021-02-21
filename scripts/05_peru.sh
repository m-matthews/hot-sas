#!/usr/bin/env bash

# Download peru-latest.osm.pbf from http://download.geofabrik.de/south-america.html

osmosis --read-pbf ./peru-latest.osm.pbf \
        --bounding-box top=-13.153 left=-72.551 bottom=-13.868 right=-71.374 \
        --tf accept-ways --tf reject-relations \
        --way-key keyList="building" --used-node \
        --write-xml cusco_buildings.osm
