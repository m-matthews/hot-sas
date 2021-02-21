********************************************************************************;
* 05_covid19_peru.sas                                                          *;
* -------------------                                                          *;
* Display the buildings added to OpenStreetMap during the Humanitarian         *;
* OpenStreetMap Team projects related to Covid-19 in the Cusco region of Peru. *;
********************************************************************************;

filename osm_map "/folders/myfolders/hot-sas/data/osm_map.xml";
libname osm_data xmlv2 "/folders/myfolders/hot-sas/data/cusco_buildings.osm"
                 xmlmap=osm_map;

proc sql;
  create table work.cusco_buildings as
    select w.id, w.timestamp, w.version,
           wt.value as type,
           mean(n.lat) as lat,
           mean(n.lon) as lon
      from osm_data.ways as w,
           osm_data.way_tags as wt,
           osm_data.way_nodes as wn,
           osm_data.nodes as n
         where wt.key="building" and
               w.id = wt.id and w.id = wn.id and
               wt.id = wn.id and wn.ref = n.id
           group by w.id, w.timestamp, w.version, wt.value
             order by id;
quit;

proc print data=work.cusco_buildings(obs=5);
run;

ods path(prepend) work.templat(update);

proc template;
  define style styles.mystyle;
    parent=styles.htmlblue;
    style GraphData1 from GraphData1 /
          color=darkblue contrastcolor=blue
          markersymbol="circlefilled" markersize=1px linethickness=1px;
  end;
run;

ods listing gpath="/folders/myfolders/hot-sas/images" style=styles.mystyle;

ods graphics / imagename="05_peru_01" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.cusco_buildings noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Cusco Region Buildings";
  scatter x=lon y=lat / markerattrs=(symbol=circlefilled color=blue size=2px);
run;

ods graphics reset;

* Create Hexagonal plots to show the density.                                  *;
* Note that this requires SAS/STAT.                                            *;
ods select none;
ods output fitplot=work.hexmap;
proc surveyreg data=work.cusco_buildings
               plots(nbins=70 weight=heatmap)=fit(shape=hex);
  model lat=lon;
run;
ods select all;

proc print data=work.hexmap(obs=12);
run;

* Create mapping into bands.                                                   *;
proc format;
  value hexgrp 1-5='A'
               6-10='B'
               11-25='C'
               26-80='D'
               81-250='E'
               251-500='F'
               501-2000='G'
               2001-high='H';
  value $hexgrp 'A'='1-5'
                'B'='6-10'
                'C'='11-25'
                'D'='26-80'
                'E'='81-250'
                'F'='251-500'
                'G'='501-2000'
                'H'='2001+';
run;

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

proc sort data=work.hexmap_resp;
  by gvar;
run;

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

ods graphics / imagename="05_peru_02" imagefmt=png width=800px height=600px border=off;

proc sgmap mapdata=work.hexmap_map
           maprespdata=work.hexmap_resp;
  esrimap url='http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map';
  title h=2 "Cusco Region Buildings";
  choromap gvar / name="hexes" lineattrs=(color=gray) transparency=0.25;
  keylegend "hexes" / title="Building Count";
run;

ods graphics reset;

* Buildings with appromiate on when entered into OpenStreetMap.                *;
data work.cusco_updates;
  set work.cusco_buildings;
  if timestamp<"01FEB2020:00:00"dt then status="Old    ";
  else if version=1 then status="Recent";
  else status="Updated";
run;

proc sort data=work.cusco_updates;
  by status;
run;

proc template;
  define style styles.mystyle;
    parent=styles.htmlblue;
    style GraphData1 from GraphData1 /
          color=darkblue contrastcolor=darkblue /* blue */
          markersymbol="circlefilled" markersize=1px linethickness=1px;
    style GraphData2 from GraphData2 /
          color=darkred contrastcolor=green /* vibg /* vipb /* darkred /* cyan /* vilg /* cyan */
          markersymbol="circlefilled" markersize=1px linethickness=1px;
    style GraphData3 from GraphData3 /
          color=darkred contrastcolor=blue /* delg /* bibg vibg darkcyan */
          markersymbol="circlefilled" markersize=1px linethickness=1px;
  end;
run;

ods graphics / imagename="05_peru_03" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.cusco_updates;
  esrimap url='http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map';
  title h=2 "Cusco Region Buildings";
  scatter x=lon y=lat / group=status name="buildings"
          markerattrs=(symbol=circlefilled size=2px);
  keylegend "buildings" / title="";
run;

ods graphics reset;
