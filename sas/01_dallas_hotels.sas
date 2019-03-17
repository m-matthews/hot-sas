********************************************************************************;
* 01_dallas_hotels.sas                                                         *;
* --------------------                                                         *;
* Display the location of the hotels in Dallas using the OpenStreetMap         *;
* Overpass API.                                                                *;
********************************************************************************;

filename spec "/folders/myfolders/hot-sas/data/dallas_hotels_spec.txt";
filename resp "/folders/myfolders/hot-sas/data/dallas_hotels.json";

data _null_;
   file spec;
   input; 
   put _infile_;
   datalines4;
[out:json][timeout:25];
(area[name="Dallas"];)->.searchArea;
(
  node["tourism"="hotel"](area.searchArea);
);
out body;
(
  way["tourism"="hotel"](area.searchArea);
  rel["tourism"="hotel"](area.searchArea);
  rel["name"="Kay Bailey Hutchinson Convention Center"](area.searchArea);
);
out center;
;;;;
run;

proc http url="http://overpass-api.de/api/interpreter" 
          in=spec out=resp
          method="post"
          ct="application/x-www-form-urlencoded";
run;

libname hotels JSON fileref=resp;

data work.hotel_details(drop=ordinal_elements);
  merge hotels.elements(keep=id ordinal_elements lat lon)
        hotels.elements_tags(keep=ordinal_elements name)
        hotels.elements_center(keep=ordinal_elements lat lon);
  by ordinal_elements;
  if name="Kay Bailey Hutchinson Convention Center" then
    type="SASGF";
  else type="Hotel";
run;

proc print data=work.hotel_details(obs=5);
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

ods graphics / imagename="01_dallas_hotels" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.hotel_details(where=(lat<32.9 and lon<-96.7));
  openstreetmap;
  title h=2 "Dallas Hotels";
  scatter x=lon y=lat / name="hotels" group=type markerattrs=(symbol=starfilled size=15px);
  keylegend "hotels" / title="";
run;

ods graphics reset;
