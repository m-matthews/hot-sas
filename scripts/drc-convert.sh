#!/usr/bin/env bash

# Download congo-democratic-republic-latest.osm.pbf from http://download.geofabrik.de/africa.html

# Convert the nodes into CSV format.
osmconvert ../data/congo-democratic-republic-latest.osm.pbf --drop-ways --drop-relations --csv="@id @timestamp @lat @lon" --csv-headline -o=../data/drc-nodes.csv

# Create the list of cities and towns in CSV format.
osmosis --read-pbf file=../data/congo-democratic-republic-latest.osm.pbf --nkv keyValueList="place.city,place.town" --write-xml ../data/drc-city-town.osm

osmconvert ../data/drc-city-town.osm --csv="@id @lat @lon place name" --csv-headline -o=../data/drc-city-town.csv
