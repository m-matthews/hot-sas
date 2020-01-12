********************************************************************************;
* 01_maryland_airports.sas                                                     *;
* ------------------------                                                     *;
* Display the location of all IATA coded airports in Maryland using the        *;
* OpenStreetMap Overpass API.                                                  *;
********************************************************************************;

filename spec "/folders/myfolders/hot-sas/data/maryland_airports_spec.txt";
filename resp "/folders/myfolders/hot-sas/data/maryland_airports.json";

data _null_;
   file spec;
   input; 
   put _infile_;
   datalines4;
[out:json][timeout:25];
(area[name="Maryland"];)->.searchArea;
(
  node["aeroway"="aerodrome"]["iata"](area.searchArea);
);
out body;
(
  way["aeroway"="aerodrome"]["iata"](area.searchArea);
  rel["aeroway"="aerodrome"]["iata"](area.searchArea);
);
out center;
;;;;
run;

proc http url="http://overpass-api.de/api/interpreter" 
          in=spec out=resp
          method="post"
          ct="application/x-www-form-urlencoded";
run;

libname airports JSON fileref=resp;

data work.airport_details(drop=ordinal_elements);
  merge airports.elements(keep=id ordinal_elements lat lon)
        airports.elements_tags(keep=ordinal_elements name iata)
        airports.elements_center(keep=ordinal_elements lat lon);
  by ordinal_elements;
run;

proc print data=work.airport_details(obs=5)
           style(data header n obs obsheader table)={fontsize=12pt};
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.htmlblue;

ods graphics / imagename="01_maryland_airports" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.airport_details noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base";
  title h=2 "Maryland Airports";
  scatter x=lon y=lat / markerattrs=(symbol=diamondfilled size=10px color=Green)
                        datalabel=iata datalabelpos=top
                        datalabelattrs=(color=black family=Arial size=9);
run;

ods graphics reset;
