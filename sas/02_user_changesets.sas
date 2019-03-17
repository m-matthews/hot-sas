********************************************************************************;
* 01_dallas_hotels.sas                                                         *;
* --------------------                                                         *;
* Display the location of the hotels in Dallas using the OpenStreetMap         *;
* Overpass API.                                                                *;
********************************************************************************;

filename osm_map "/folders/myfolders/hot-sas/data/osm_map.xml";
filename chgsets "/folders/myfolders/hot-sas/data/user_changesets.xml";

%let user=%sysfunc(sysget(OSM_USER));

proc http url="https://www.openstreetmap.org//api/0.6/changesets?display_name=&user"
          method="get"
          out=chgsets;
run;

libname osm_cs xmlv2 "/folders/myfolders/hot-sas/data/user_changesets.xml"
               xmlmap=osm_map;

proc sort data=osm_cs.changesets out=work.changesets;
  by id;
run;

proc sort data=osm_cs.changeset_tags out=work.changeset_tags;
  by id;
run;

data work.osm_changesets(keep=id created_at changes_count comment lat lon);
  merge work.changesets
        work.changeset_tags(where=(key="comment")
                            rename=(value=comment));
  by id;
  lat = mean(min_lat, max_lat);
  lon = mean(min_lon, max_lon);
run;

proc print data=work.osm_changesets(obs=5);
run;

ods path(prepend) work.templat(update);

proc template;
  define style styles.mystyle;
    parent=styles.htmlblue;
    style GraphDataDefault from GraphDataDefault /
          color=lightblue;
    style GraphOutlines from GraphOutlines /
          contrastcolor=blue linestyle=1;
  end;
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.htmlblue;

ods graphics / imagename="02_user_changesets_ns" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.osm_changesets noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "OpenStreetMap Changesets";
  bubble x=lon y=lat size=changes_count;
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.mystyle;

ods graphics / imagename="02_user_changesets_ws" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.osm_changesets noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "OpenStreetMap Changesets";
  bubble x=lon y=lat size=changes_count / bradiusmin=2px bradiusmax=8px;
run;

ods graphics reset;
