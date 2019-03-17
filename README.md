# hot-sas

> Analysis of [OpenStreetMap](https://www.openstreetmap.org) and the [Humanitarian OpenStreetMap Team](https://www.hotosm.org) data using [SAS Software](https://www.sas.com).


## Overview

The [Humanitarian OpenStreetMap Team](https://www.hotosm.org) (HOT) community consists of volunteers from around the globe.  HOT tasks involve developing maps that identify communities and infrastructures based on satellite imagery.  These maps are then used to assist aid organizations such as the Red Cross during humanitarian crises and for general community development in areas that are often not covered by the mapping products that most of us take for granted.

This repository examines [OpenStreetMap](https://www.openstreetmap.org) data and introduces HOT and some of the associated mapping tasks, including assisting the aid efforts during the May 2018 Ebola outbreak in the Democratic Republic of the Congo.

Analysis is performed on the data using the SAS® ODS Graphics procedures (including PROC SGMAP) to visualize the contributions to OpenStreetMap both spatially and over time.


## 1. Hotels in Dallas

The first program [01_dallas_hotels.sas](sas/01_dallas_hotels.sas) provides an example of extracting the OpenStreetMap data for all of the Hotels in Dallas using the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API).

The PROC SGMAP output includes using OpenStreetMap tiles for the background, and the markers are based on buildings tagged in the OpenStreetMap data:

![PROC SGMAP - Dallas Hotels](images/01_dallas_hotels.png "PROC SGMAP - Dallas Hotels")


## 2. OpenStreetMap Changesets

The program [02_user_changesets.sas](sas/02_user_changesets.sas) introduces the OpenStreetMap XML format and how to read this with SAS Software.

The PROC SGMAP output shows the last 100 edits for a contributor to OpenStreetMap using the ESRI World Topographical background tiles:

![PROC SGMAP - OpenStreetMap User Changesets](images/02_user_changesets_ws.png "PROC SGMAP - OpenStreetMap User Changesets")


## 3. Humanitarian OpenStreetMap Team Global Tasks

The program [03_hotosm_tasks.sas](sas/03_hotosm_tasks.sas) shows the location of the many tasks completed by contributors to the Humanitarian OpenStreetMap Team.

The first display shows the location of the global tasks using PROC SGMAP with ESRI World Topographical background tiles:

![PROC SGMAP - HOTOSM Tasks](images/03_hotosm_tasks_all.png "PROC SGMAP - HOTOSM Tasks")

The second display shows how PROC SGMAP with a simple WHERE clause on the input data will adjust the boundaries of the generated map to show tasks in Africa:

![PROC SGMAP - HOTOSM Tasks / Africa](images/03_hotosm_tasks_africa.png "PROC SGMAP - HOTOSM Tasks / Africa")


## 4. Humanitarian OpenStreetMap Team Global Tasks

The final program [04_hotosm_drc.sas](sas/04_hotosm_drc.sas) details the extraction of OpenStreetMap data from [Geofabrik](https://download.geofabrik.de) for the [Democratic Republic of the Congo](https://en.wikipedia.org/wiki/Democratic_Republic_of_the_Congo).  This data is then used to perform analyses on the number of edits to OpenStreetMap during 2018 to support the Ebola crises.

The first output shows a scatter plot of the node edits during May 2018:

![PROC SGPLOT - HOTOSM Nodes](images/04_hotosm_drc_sgmap.png "PROC SGPLOT - HOTOSM Nodes")

The second output shows this same data represented using hexagonal binning which can help to visualise the node density which may be lost in the previous display:

![PROC SGPLOT - HOTOSM Nodes HexMap](images/04_hotosm_drc_hexmap.png "PROC SGPLOT - HOTOSM Nodes HexMap")

Due to the presence of hot spots outside of the north west where the Ebola crisis was present, an overlapping chart is produced to review the location of population centres which will be the subject of frequent changes due to normal OpenStreetMap updates:

![PROC SGPLOT - HOTOSM Nodes HexMap and Cities](images/04_hotosm_drc_hexmap_cities.png "PROC SGPLOT - HOTOSM Nodes HexMap and Cities")

The final result is a sequence of images, which are then processed with [ImageMagick®](https://www.imagemagick.org/) to create an animation with smooth transitions between frames:

The Animation output is available on [YouTube](https://youtu.be/brvmSHEmhWU).

An alternative to the hexagonal binning is to review the data at the node level using scatter plot techniques.  This can give an alternative view of the data, although obviously hides the density of edits.

In this example the individual frames also include a fade effect, with the current weeks data bright yellow, and subsequent weeks each in a darker colour:

![PROC SGPLOT - HOTOSM Nodes](images/04_drc_plotweek_2018-05-20.png "PROC SGPLOT - HOTOSM Nodes")

The final result is a sequence of images, which are then processed again with ImageMagick to create an animation with smooth transitions between frames:

The Animation output is available on [YouTube](https://youtu.be/bNx4RK6TPrA).
