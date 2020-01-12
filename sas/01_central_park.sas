********************************************************************************;
* 01_central_park.sas                                                          *;
* -------------------                                                          *;
* Display the outline of Central Park in New York using the OpenStreetMap      *;
* Overpass API.                                                                *;
********************************************************************************;

filename spec "/folders/myfolders/hot-sas/data/central_park_spec.txt";
filename resp "/folders/myfolders/hot-sas/data/central_park.json";

data _null_;
   file spec;
   input; 
   put _infile_;
   datalines4;
[out:json][timeout:25];
(area[name="Manhattan"];)->.searchArea;
(
  way["name"="Central Park"](area.searchArea);
);
(._;>;);
out;
;;;;
run;

proc http url="http://overpass-api.de/api/interpreter" 
          in=spec out=resp
          method="post"
          ct="application/x-www-form-urlencoded";
run;

libname centpark JSON fileref=resp;

data work.order(keep=pos id);
  set centpark.elements_nodes;
  array n nodes:;
  do pos=1 to dim(n);
    id=n[pos];
    output;
  end;
run;

proc sql noprint;
  create table work.central_park_details as
    select o.pos, o.id, e.lat, e.lon
      from work.order o, centpark.elements e
        where o.id=e.id
          order by o.pos;
quit;

proc print data=work.central_park_details(obs=5)
           style(data header n obs obsheader table)={fontsize=12pt};
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.htmlblue;

ods graphics / imagename="01_central_park" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.central_park_details noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base";
  title h=2 "Central Park";
  series x=lon y=lat / lineattrs=(color=Green);
run;

ods graphics reset;
