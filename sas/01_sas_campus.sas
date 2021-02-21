********************************************************************************;
* 01_sas_campus.sas                                                            *;
* --------------------                                                         *;
* Display the location of the buildings and sculptures on the SAS Campus using *;
* the OpenStreetMap Overpass API.                                              *;
********************************************************************************;

filename spec "/folders/myfolders/hot-sas/data/sas_campus_spec.txt";
filename resp "/folders/myfolders/hot-sas/data/sas_campus.xml";

* Initial extract of the buildings in "Cary".                                  *;
data _null_;
   file spec;
   input; 
   put _infile_;
   datalines4;
[out:xml][timeout:25];
(area[name="Cary"];)->.searchArea;
(
  way["name"~"SAS Building"](area.searchArea);
);
out center;
;;;;
run;

proc http url="http://overpass-api.de/api/interpreter" 
          in=spec out=resp
          method="post"
          ct="application/x-www-form-urlencoded";
run;

filename osm_map "/folders/myfolders/hot-sas/data/osm_map.xml";
libname osm_data xmlv2 "%sysfunc(pathname(resp))" xmlmap=osm_map;

data work.sas_buildings(keep=id center_lat center_lon value building
                        rename=(center_lat=lat center_lon=lon value=name));
  merge osm_data.ways(keep=id center_lat center_lon)
        osm_data.way_tags(keep=id key value
                          where=(key="name"));
  by id;
  building=scan(value,-1," ");
run;

proc print data=work.sas_buildings;
  title "SAS Campus building details.";
run;

* Extract of buildings and sculptures within a specific bounding box.          *;
data _null_;
   file spec;
   input; 
   put _infile_;
   datalines4;
[out:xml][timeout:25];
(
  node["tourism"="artwork"](35.815, -78.767, 35.829, -78.749);
);
out body;
(
  way["name"~"SAS Building"](35.815, -78.767, 35.829, -78.749);
);
out center;
;;;;
run;

proc http url="http://overpass-api.de/api/interpreter" 
          in=spec out=resp
          method="post"
          ct="application/x-www-form-urlencoded";
run;

filename osm_map "/folders/myfolders/hot-sas/data/osm_map.xml";
libname osm_data xmlv2 "%sysfunc(pathname(resp))" xmlmap=osm_map;

data work.sas_combined(keep=id lat lon value type building
                       rename=(value=name));
  merge osm_data.nodes(keep=id lat lon
                       in=node)
        osm_data.node_tags(keep=id key value
                           where=(key="name"))
        osm_data.ways(keep=id center_lat center_lon
                      rename=(center_lat=lat center_lon=lon)
                      in=way)
        osm_data.way_tags(keep=id key value
                          where=(key="name"));
  by id;
  type=ifc(way,"Building","Sculpture");
  if way then building=scan(value,-1," ");
run;

proc print data=work.sas_combined;
  title "SAS Campus building and sculpture details.";
run;

ods path(prepend) work.templat(update);

proc template;
  define style styles.mystyle;
    parent=styles.htmlblue;
    style GraphData1 from GraphData1 /
          contrastcolor=darkblue linestyle=1;
    style GraphData2 from GraphData2 /
          contrastcolor=red linestyle=1;
  end;
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.mystyle;

ods graphics / imagename="01_sas_dampus" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.combined;
  openstreetmap;
  title h=2 "SAS Campus";
  scatter x=lon y=lat / name="buildings" group=type
                        markerattrs=(symbol=diamondfilled size=10px)
                        datalabel=building datalabelpos=right
                        datalabelattrs=(color=black family=Arial size=7);
  keylegend "buildings" / title="";
run;

ods graphics reset;
