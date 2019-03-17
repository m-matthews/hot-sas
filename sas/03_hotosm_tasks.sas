********************************************************************************;
* 03_hotosm_tasks.sas                                                          *;
* -------------------                                                          *;
* Display the location of global Humanitarian OpenStreetMap Team tasks.        *;
********************************************************************************;

proc import datafile="/folders/myfolders/hot-sas/data/hotosm_summary.csv"
            out=work.hotosm_summary
            dbms=csv
            replace;
run;

data work.hotosm_summary;
  set work.hotosm_summary(keep=id lat lon name);
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.htmlblue;

ods graphics / imagename="03_hotosm_tasks_all" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.hotosm_summary noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Humanitarian OpenStreetMap Team Tasks";
  scatter x=lon y=lat / markerattrs=(symbol=circle color=blue size=4px);
run;

* Apply a WHERE clause to select the lat/lon range for Africa.                 *;
ods graphics / imagename="03_hotosm_tasks_africa" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.hotosm_summary noautolegend;
  where lat between -35 and 35 and
        lon between -29 and 57;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Humanitarian OpenStreetMap Team Tasks";
  scatter x=lon y=lat / markerattrs=(symbol=circle color=blue size=4px);
run;

ods graphics reset;
