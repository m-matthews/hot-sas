#!/usr/bin/env bash

# Download italy-latest.osm.pbf from http://download.geofabrik.de/europe.html

osmosis --read-pbf ./italy-latest.osm.pbf \
        --node-key keyList="opening_hours:covid19,delivery:covid19,takeaway:covid19,access:covid19,capacity:covid19,drive_through:covid19" \
        --write-xml italy_covid19_nodes.osm

osmosis --read-pbf ./italy-latest.osm.pbf \
        --tf accept-ways --tf reject-relations \
        --way-key keyList="opening_hours:covid19,delivery:covid19,takeaway:covid19,access:covid19,capacity:covid19,drive_through:covid19" \
        --used-node --write-xml italy_covid19_ways.osm
