********************************************************************************;
* 01_washington_hotels.sas                                                     *;
* ------------------------                                                     *;
* Display the location of the hotels in Washington D.C. using the              *;
* OpenStreetMap Overpass API.                                                  *;
********************************************************************************;

filename spec "/folders/myfolders/hot-sas/data/washington_hotels_spec.txt";
filename resp "/folders/myfolders/hot-sas/data/washington_hotels.json";

data _null_;
   file spec;
   input; 
   put _infile_;
   datalines4;
[out:json][timeout:25];
(area[name="District of Columbia"];)->.searchArea;
(
  node["tourism"="hotel"](area.searchArea);
);
out body;
(
  way["tourism"="hotel"](area.searchArea);
  rel["tourism"="hotel"](area.searchArea);
  way["name"="Walter E. Washington Convention Center"](area.searchArea);
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
  if name="Walter E. Washington Convention Center" then
    type="SASGF";
  else type="Hotel";
run;

data work.hotel_details;
  set work.hotel_details;
  where id not in (367144559, 737405114);
run;

proc print data=work.hotel_details(obs=5)
           style(data header n obs obsheader table)={fontsize=12pt};
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

ods graphics / imagename="01_washington_hotels" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.hotel_details;
  openstreetmap;
  title h=2 "Washington D.C. Hotels";
  scatter x=lon y=lat / name="hotels" group=type markerattrs=(symbol=diamondfilled size=10px);
  keylegend "hotels" / title="";
run;

ods graphics reset;
