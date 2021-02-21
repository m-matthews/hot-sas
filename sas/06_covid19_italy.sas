********************************************************************************;
* 05_covid19_italy.sas                                                         *;
* --------------------                                                         *;
* Display the OpenStreetMap objects tagged with the new Covid19 related tags.  *;
********************************************************************************;

filename osm_map "/folders/myfolders/hot-sas/data/osm_map.xml";
libname osm_itan xmlv2 "/folders/myfolders/hot-sas/data/italy/italy_covid19_nodes.osm"
                 xmlmap=osm_map;
libname osm_itaw xmlv2 "/folders/myfolders/hot-sas/data/italy/italy_covid19_ways.osm"
                 xmlmap=osm_map;

data work.tags;
  set osm_itan.node_tags
      osm_itaw.way_tags;
  where key contains "covid19";
  label key="Key";
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

ods graphics / imagename="06_italy_01" imagefmt=png width=800px height=600px border=off;

proc sgplot data=work.tags noautolegend;
  hbar key / categoryorder=respdesc;
  xaxis display=(noline noticks) grid valuesformat=comma6.;
run;

ods graphics reset;

proc sql;
  create table work.combined as
    select id, lat, lon, "Node" as type
      from osm_itan.nodes
        union corresponding
    select w.id,
           mean(n.lat) as lat,
           mean(n.lon) as lon,
           "Way" as type
      from osm_itaw.ways as w,
           osm_itaw.way_nodes as wn,
           osm_itaw.nodes as n
         where w.id = wn.id and
               wn.ref = n.id
           group by w.id
             order by id;
quit;

ods graphics / imagename="06_italy_02" imagefmt=png width=800px height=600px border=off;

proc sgmap plotdata=work.combined noautolegend;
  esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
  title h=2 "Italian Covid19 Tags";
  scatter x=lon y=lat / markerattrs=(symbol=circlefilled color=blue size=2px);
run;

ods graphics reset;

ods graphics / imagename="06_italy_03" imagefmt=png width=800px height=600px border=off;

%let b_lat=44.495;
%let b_lon=11.343;
%let b_size=0.25;

proc sgmap plotdata=work.combined noautolegend;
  where lat between &b_lat-&b_size and &b_lat+&b_size and
        lon between &b_lon-&b_size and &b_lon+&b_size;
  openstreetmap;
  title h=2 "Bologna Covid19 Tags";
  scatter x=lon y=lat / markerattrs=(symbol=circlefilled color=blue size=5px);
run;

ods graphics reset;
