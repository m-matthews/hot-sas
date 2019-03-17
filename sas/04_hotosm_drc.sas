********************************************************************************;
* 04_hotosm_drc.sas                                                            *;
* -----------------                                                            *;
* Display the OpenStreetMap edits to the Democratic Republic of the Congo      *;
* during 2018.                                                                 *;
********************************************************************************;

* The file drc-nodes.csv is created by the script "drc-convert.sh".            *;
proc import datafile="/folders/myfolders/hot-sas/data/drc-nodes.csv"
            out=work.drc_nodes
            dbms=dlm
            replace;
  delimiter="09"x;
run;

proc print data=work.drc_nodes(obs=10);
run;

* Note that the following where clause excludes points in the data file that   *;
* are outside the Democratic Republic of the Congo.                            *;
data work.nodesv(keep=lat lon month week) / view=work.nodesv;
  set work.drc_nodes(rename=(_lat=lat _lon=lon _timestamp=timestamp));
  where timestamp ge '01jan2018:00:00'dt and
        not (
             (lon>29 and lat between -13 and -10) or
              lat>5 or
             (lon>30 and lat between -9 and -5) or
             (lon>29 and lat between -6 and -5)
        );
  month = intnx('MONTH', datepart(timestamp), 0);
  week = intnx('WEEK', datepart(timestamp), 0);
  format month monyy7. week yymmddd10.;
run;

proc sort data=work.nodesv out=work.nodes(index=(month));
  by month;
run;

proc datasets lib=work nolist;
  delete drc_nodes;
run;
quit;

* Create scatter plot of the node edits during May 2018.                       *;
ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.htmlblue;

ods graphics / imagename="04_hotosm_drc_sgmap" imagefmt=png width=800px height=600px border=off maxobs=15000000;

proc sgmap plotdata=work.nodes(where=(month="01may2018"d))
           noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Democratic Republic of the Congo: OSM Node Edits";
  title2 h=1.5 "May2018";
  scatter x=lon y=lat / markerattrs=(symbol=circle color=blue size=2px);
run;

ods graphics reset;

* Use PROC SURVEYREG to create hexagonal binning regions and values.           *;
ods select none;
ods output fitplot=work.HexMap;
proc surveyreg data=work.nodes
               plots(nbins=70 weight=heatmap)=fit(shape=hex);
  where month="01May2018"d;
  model lat=lon;
run;
ods select all;

* PROC FORMAT creates ranges for the display.                                  *;
proc format;
  value hexgrp 1-4="A"
               5-9="B"
               10-49="C"
               50-199="D"
               200-499="E"
               500-1999="F"
               2000-6999="G"
               7000-high="H";
  value $hexgrp "A"="1-4"
                "B"="5-9"
                "C"="10-49"
                "D"="50-199"
                "E"="200-499"
                "F"="500-1999"
                "G"="2000-6999"
                "H"="7000+";
run;

* Convert the PROC SURVEYREG output into data suitable for SGMAP.              *;
data work.hexmap_map(keep=id x y)
     work.hexmap_resp(keep=id wvar gvar);
  set work.hexmap(rename=(hid=id xvar=x yvar=y));
  where id ne .;
  by id;
  output work.hexmap_map;
  if last.id;
  gvar=put(wvar,hexgrp.);
  format gvar $hexgrp.;
  output work.hexmap_resp;
run;
* The order is required to ensure the colour bands are applied correctly.      *;
proc sort data=work.hexmap_resp;
  by gvar;
run;

* Create colour bands suitable for the PROC FORMAT ranges.                     *;
ods path(prepend) work.templat(update);

proc template;
  define style styles.myrampstyle;
    parent=styles.htmlblue;
    style GraphData1 from GraphData1 /
          contrastcolor=cxDFDFEF linestyle=1;
    style GraphData2 from GraphData2 /
          contrastcolor=cxBFBFDF linestyle=1;
    style GraphData3 from GraphData3 /
          contrastcolor=cx9F9FCF linestyle=1;
    style GraphData4 from GraphData4 /
          contrastcolor=cx8080C0 linestyle=1;
    style GraphData5 from GraphData5 /
          contrastcolor=cx6060B0 linestyle=1;
    style GraphData6 from GraphData6 /
          contrastcolor=cx4040A0 linestyle=1;
    style GraphData7 from GraphData7 /
          contrastcolor=cx202090 linestyle=1;
    style GraphData8 from GraphData8 /
          contrastcolor=cx000080 linestyle=1;
    style GraphColors from graphcolors /
          "gdata1" = cxDFDFEF
          "gdata2" = cxBFBFDF
          "gdata3" = cx9F9FCF
          "gdata4" = cx8080C0
          "gdata5" = cx6060B0
          "gdata6" = cx4040A0
          "gdata7" = cx202090
          "gdata8" = cx000080;
  end;
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.myrampstyle;

ods graphics / imagename="04_hotosm_drc_hexmap" imagefmt=png width=800px height=600px border=off;

proc sgmap mapdata=work.hexmap_map
           maprespdata=work.hexmap_resp;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Democratic Republic of the Congo: OSM Node Edits";
  title2 h=1.5 "May2018";
  choromap gvar / name="hexes" lineattrs=(color=gray) transparency=0.25;
  keylegend "hexes" "Nodes";
run;

* The file drc-city-town.csv is created by the script "drc-convert.sh".        *;
proc import datafile="/folders/myfolders/hot-sas/data/drc-city-town.csv"
            out=work.citytown
            dbms=dlm
            replace;
  delimiter="09"x;
run;

proc print data=work.citytown(obs=10);
run;

data work.citytown(keep=lat_c lon_c lat_t lon_t place name);
  set work.citytown(rename=(_lat=lat _lon=lon));
  if place="city" then do;
    lat_c=lat;
    lon_c=lon;
  end;
  else do;
    lat_t=lat;
    lon_t=lon;
  end;
run;

ods graphics / imagename="04_hotosm_drc_hexmap_cities" imagefmt=png width=800px height=600px border=off;

proc sgmap mapdata=work.hexmap_map
           maprespdata=work.hexmap_resp
           plotdata=work.citytown;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Democratic Republic of the Congo: OSM Node Edits";
  choromap gvar / name="hexes" lineattrs=(color=gray) transparency=0.5;
  scatter x=lon_c y=lat_c / markerattrs=(symbol=circlefilled color=darkgreen size=5px);
  scatter x=lon_t y=lat_t / markerattrs=(symbol=circlefilled color=darkblue size=2px);
  keylegend "hexes" "Nodes";
run;

* Create points outside existing data range to use in all PROC SGMAP output    *;
* to ensure the generated regions are consistent for linking as an animation.  *;
proc summary data=work.nodes nway;
  var lat lon;
  output out=work.summary(drop=_type_ _freq_)
         min(lat lon)=min_lat min_lon
         max(lat lon)=max_lat max_lon;
run;

data work.plot_limits(keep=x y);
  set work.summary;
  x=min_lon-1; y=min_lat-1; output;
  x=max_lon+1; y=max_lat+1; output;
run;

* Summarise all data by month to enable SGMAP hexagonal binning animation.     *;
%macro summarise;
  proc sql noprint;
    create table work.months as
      select distinct month
        from work.nodes
          order by month;
    select put(month, monyy7.)
      into :months
        separated by ' '
          from work.months;
    select cats("work.hexmap_",put(month, monyy7.),"(in=in_",put(month, monyy7.),")")
      into :months_set
        separated by ' '
          from work.months;
    select cats("if in_",put(month, monyy7.),"=1 then month=""01",put(month, monyy7.),"""d")
      into :months_in
        separated by ';'
          from work.months;
  quit;

  %let i=1;
  %let hexmapds=;
  %do %while(%scan(&months, &i) ne );
    %let month = %scan(&months, &i);
    %put NOTE: Month=&month;

    ods select none;
    ods output fitplot=work.HexMap_&month;
    proc surveyreg data=work.nodes plots(nbins=70 weight=heatmap)=fit(shape=hex);
      where month="01&month"d and
            lat between -35 and 35 and
            lon between -29 and 57;
      model lat=lon;
    run;
    ods select all;

    %let i=%eval(&i+1);
  %end;

  data work.hexmap_combined;
    format month monyy7.;
    set &months_set;
    where hid ne .;
    &months_in;
  run;
%mend;
%summarise;

data work.hexmap_map(keep=month id x y)
     work.hexmap_resp(keep=month id wvar gvar);
  set work.hexmap_combined(rename=(hid=id xvar=x yvar=y));
  by month id;
  where id ne .;
  output work.hexmap_map;
  if last.id;
  gvar=put(wvar,hexgrp.);
  format gvar $hexgrp.;
  output work.hexmap_resp;
run;
proc sort data=work.hexmap_resp;
  by month gvar;
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.myrampstyle;

ods graphics / imagename="04_hotosm_drc_hexmap" imagefmt=png width=800px height=600px border=off;

%macro chart(month, filename);
  ods graphics / imagename="&filename" imagefmt=png width=800px height=600px border=off;

  proc sgmap mapdata=work.hexmap_map(where=(month="01&month"d))
             maprespdata=work.hexmap_resp(where=(month="01&month"d))
             plotdata=work.plot_limits;
    esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
    title h=2 "Democratic Republic of the Congo: OSM Node Edits";
    title2 h=1.5 "&month";
    choromap gvar / name="hexes" lineattrs=(color=gray) transparency=0.25;
    scatter x=x y=y / transparency=1;
    keylegend "hexes" "Nodes";
  run;
%mend;

data _null_;
  do i=0 to 12;
    month=intnx("MONTH", "01jan2018"d, i);
    c=cats('%chart(', propcase(put(month,monyy7.)), ',04_drc_hexmonth_', put(month,yymmddd10.), ');');
    call execute(c);
  end;
run;

* Weekly scatter plot of node edits.                                           *;
ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.htmlblue;

%macro plot(week, filename);
  ods graphics / imagename="&filename" imagefmt=png width=800px height=600px border=off;

  data work.plotdata(keep=w1: w2: w3: w4: x y);
    set work.nodes
        work.plot_limits(in=lim);
    format week;
    if _n_=1 then do;
      retain w1 w2 w3 w4;
      w1="&week"d;
      w2=intnx("WEEK", w1, -1);
      w3=intnx("WEEK", w1, -2);
      w4=intnx("WEEK", w1, -3);
    end;
    select(week);
      when(w1) do;
        w1_lat=lat;
        w1_lon=lon;
      end;
      when(w2) do;
        w2_lat=lat;
        w2_lon=lon;
      end;
      when(w3) do;
        w3_lat=lat;
        w3_lon=lon;
      end;
      when(w4) do;
        w4_lat=lat;
        w4_lon=lon;
      end;
      otherwise do;
        if not lim then delete;
      end;
    end;
  run;

  proc sgmap plotdata=work.plotdata noautolegend;
    esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
    title h=2 "Democratic Republic of the Congo: OSM Node Edits";
    title2 h=1.5 "%sysfunc(propcase(%substr(&week,3)))";
    scatter x=x y=y / transparency=1;
    scatter x=w1_lon y=w1_lat / markerattrs=(symbol=circle color=cxFFFF22 size=1px);
    scatter x=w2_lon y=w2_lat / markerattrs=(symbol=circle color=cxC5C517 size=1px);
    scatter x=w3_lon y=w3_lat / markerattrs=(symbol=circle color=cx8A8A0B size=1px);
    scatter x=w4_lon y=w4_lat / markerattrs=(symbol=circle color=cx505000 size=1px);
  run;
%mend;

data _null_;
  do i=0 to 54;
    week=intnx("WEEK", "07Jan2018"d, i);
    c=cats('%plot(', propcase(put(week,date9.)), ',04_drc_plotweek_', put(week,yymmddd10.), ');');
    call execute(c);
  end;
run;

ods graphics reset;
